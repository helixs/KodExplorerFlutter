package me.xmcf.kodproject.flutterchannel.download

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.work.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap
import java.util.concurrent.TimeUnit


class DownloadPlugin private constructor(val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val flutterChannel: MethodChannel
    private val intentFilter = IntentFilter(DownloadTaskWorker.PROGRESS_EVENT)

    companion object {
        var CHANNEL = "plugin.xmcf.me/downloader"
        var TAG = "DownloadPlugin"

        fun registerWith(context: Context, messenger: BinaryMessenger): DownloadPlugin {
            return DownloadPlugin(context, messenger)
        }
    }

    init {
        flutterChannel = MethodChannel(messenger, CHANNEL)
        flutterChannel.setMethodCallHandler(this)

    }

    private val updateProcessEventReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val id = intent.getStringExtra(DownloadTaskWorker.EXTRA_ID)
            val progress = intent.getIntExtra(DownloadTaskWorker.EXTRA_PROGRESS, 0)
            val status = intent.getIntExtra(DownloadTaskWorker.EXTRA_STATUS, TaskStatus.UNDEFINED)
            sendUpdateProgress(id, status, progress)
        }
    }

    private fun sendUpdateProgress(id: String, status: Int, progress: Int) {
        val args = HashMap<String, Any>()
        args["task_id"] = id
        args["status"] = status
        args["progress"] = progress
        flutterChannel.invokeMethod("updateProgress", args)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        if (methodCall.method == "enqueue") {
            enqueue(methodCall, result)
        }
    }

    private fun enqueue(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        val savedDir = call.argument<String>("saved_dir")
        val filename = call.argument<String>("file_name")
        val headers = call.argument<String>("headers")
        val showNotification = call.argument<Boolean>("show_notification")!!
        val openFileFromNotification = call.argument<Boolean>("open_file_from_notification")!!
        val requiresStorageNotLow = call.argument<Boolean>("requires_storage_not_low")!!
        val request = buildRequest(url!!, savedDir!!, filename, headers, showNotification, openFileFromNotification, false, requiresStorageNotLow)
        WorkManager.getInstance(context).enqueue(request)
        val taskId = request.id.toString()
        result.success(taskId)
        sendUpdateProgress(taskId, TaskStatus.ENQUEUED, 0)
//        taskDao.insertOrUpdateNewTask(taskId, url, DownloadStatus.ENQUEUED, 0, filename, savedDir, headers, showNotification, openFileFromNotification)
    }
    private fun buildRequest(url: String, savedDir: String, filename: String?, headers: String?, showNotification: Boolean, openFileFromNotification: Boolean, isResume: Boolean, requiresStorageNotLow: Boolean): WorkRequest {
        return OneTimeWorkRequest.Builder(DownloadTaskWorker::class.java)
                .setConstraints(Constraints.Builder()
                        .setRequiresStorageNotLow(requiresStorageNotLow)
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build())
                .addTag(TAG)
                .setBackoffCriteria(BackoffPolicy.EXPONENTIAL, 5, TimeUnit.SECONDS)
                .setInputData(Data.Builder()
                        .putString(DownloadTaskWorker.ARG_URL, url)
                        .putString(DownloadTaskWorker.ARG_SAVED_DIR, savedDir)
                        .putString(DownloadTaskWorker.ARG_FILE_NAME, filename)
                        .putString(DownloadTaskWorker.ARG_HEADERS, headers)
                        .putBoolean(DownloadTaskWorker.ARG_SHOW_NOTIFICATION, showNotification)
                        .putBoolean(DownloadTaskWorker.ARG_OPEN_FILE_FROM_NOTIFICATION, openFileFromNotification)
                        .putBoolean(DownloadTaskWorker.ARG_IS_RESUME, isResume)
                        .build()
                )
                .build()
    }
    fun onResume() {
        LocalBroadcastManager.getInstance(context).registerReceiver(updateProcessEventReceiver, intentFilter)
    }

    fun onPause() {
        LocalBroadcastManager.getInstance(context).unregisterReceiver(updateProcessEventReceiver)
    }
}