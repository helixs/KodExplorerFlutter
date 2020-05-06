package me.xmcf.kodproject.flutterchannel.download

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.core.app.NotificationManagerCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.work.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import me.xmcf.kodproject.flutterchannel.download.DownloadStatus
import java.io.File
import java.util.*
import java.util.concurrent.TimeUnit


class DownloadPlugin private constructor(val context: Context, messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val flutterChannel: MethodChannel
    private val intentFilter = IntentFilter(DownloadTaskWorker.PROGRESS_EVENT)
    private val dbHelper by lazy { TaskDbHelper.getInstance(context) }

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
            val allLength = intent.getLongExtra(DownloadTaskWorker.EXTRA_ALL_LENGTH, 0)
            val currentLength = intent.getLongExtra(DownloadTaskWorker.EXTRA_CURRENT_LENGTH, 0)
            sendUpdateProgress(id, status, progress,allLength=allLength,currentLength = currentLength)
        }
    }

    private fun sendUpdateProgress(id: String, status: Int, progress: Int,currentLength:Long?=null,allLength:Long?=null) {
        val args = HashMap<String, Any?>()
        args["task_id"] = id
        args["status"] = status
        args["progress"] = progress
        args["current_length"] = currentLength
        args["all_length"] = allLength
        flutterChannel.invokeMethod("updateProgress", args)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "enqueue") {
            enqueue(call, result)
        } else if (call.method == "loadTasks") {
            loadTasks(call, result)
        } else if (call.method == "queryRunningTask") {
            queryRunningTask(call, result)
        } else if (call.method == "queryCompleteTask") {
            queryCompleteTask(call, result)
        } else if (call.method == "cancel") {
            cancel(call, result)
        } else if (call.method == "cancelAll") {
            cancelAll(call, result)
        } else if (call.method == "pause") {
            pause(call, result)
        } else if (call.method == "resume") {
            resume(call, result)
        } else if (call.method == "retry") {
            retry(call, result)
        } else if (call.method == "open") {
            open(call, result)
        } else if (call.method == "remove") {
            remove(call, result)
        } else {
            result.notImplemented()
        }
    }

    private fun remove(call: MethodCall, result: MethodChannel.Result) {
        val taskId = call.argument<String>("task_id")!!
        val shouldDeleteContent = call.argument<Boolean>("should_delete_content")!!
        val task = TaskDao.queryTask(dbHelper,taskId)
        if (task != null) {
            if (task.status == DownloadStatus.ENQUEUED || task.status == DownloadStatus.RUNNING) {
                WorkManager.getInstance(context).cancelWorkById(UUID.fromString(taskId))
            }
            if (shouldDeleteContent) {
                var filename: String? = task.filename
                if (filename == null) {
                    filename = task.url.substring(task.url.lastIndexOf("/") + 1, task.url.length)
                }

                val saveFilePath = task.savedDir + File.separator + filename
                val tempFile = File(saveFilePath)
                if (tempFile.exists()) {
                    tempFile.delete()
                }
            }
            TaskDao.deleteTask(dbHelper,taskId)

            NotificationManagerCompat.from(context).cancel(task.primaryId)

            result.success(null)
        } else {
            result.error("invalid_task_id", "not found task corresponding to given task id", null)
        }
    }

    private fun open(call: MethodCall, result: MethodChannel.Result) {
        val taskId = call.argument<String>("task_id")!!
        val task = TaskDao.queryTask(dbHelper,taskId)
        if (task != null) {
            if (task.status == DownloadStatus.COMPLETE) {
                val fileURL = task!!.url
                val savedDir = task!!.savedDir
                var filename: String? = task!!.filename
                if (filename == null) {
                    filename = fileURL.substring(fileURL.lastIndexOf("/") + 1, fileURL.length)
                }
                val saveFilePath = savedDir + File.separator + filename
                val intent = getOpenFileIntent(context, saveFilePath, task.mimeType)
                if (validateIntent(context, intent)) {
                    context.startActivity(intent)
                    result.success(true)
                } else {
                    result.success(false)
                }
            } else {
                result.error("invalid_status", "only success task can be opened", null)
            }
        } else {
            result.error("invalid_task_id", "not found task corresponding to given task id", null)
        }
    }

    private fun retry(call: MethodCall, result: MethodChannel.Result) {
        val taskId = call.argument<String>("task_id")!!
        val task = TaskDao.queryTask(dbHelper,taskId)
        val requiresStorageNotLow = call.argument<Boolean>("requires_storage_not_low")!!
        if (task != null) {
            if (task.status == TaskStatus.FAILED || task.status == TaskStatus.CANCELED) {
                val request = buildRequest(task.url, task.savedDir, task.filename, task.headers, task.showNotification, task.openFileFromNotification, false, requiresStorageNotLow)
                val newTaskId = request.id.toString()
                result.success(newTaskId)
                sendUpdateProgress(newTaskId, DownloadStatus.ENQUEUED, task.progress)
                TaskDao.updateTask(dbHelper,taskId, newTaskId, DownloadStatus.ENQUEUED, task.progress, false)
                WorkManager.getInstance(context).enqueue(request)
            } else {
                result.error("invalid_status", "only failed and canceled task can be retried", null)
            }
        } else {
            result.error("invalid_task_id", "not found task corresponding to given task id", null)
        }
    }


    private fun resume(call: MethodCall, result: MethodChannel.Result) {
        val taskId = call.argument<String>("task_id")
        val task = TaskDao.queryTask(dbHelper,taskId!!)
        val requiresStorageNotLow = call.argument<Boolean>("requires_storage_not_low")!!
        if (task != null) {
            if (task.status == TaskStatus.PAUSED) {
                var filename: String? = task.filename
                if (filename == null) {
                    filename = task.url.substring(task.url.lastIndexOf("/") + 1, task.url.length)
                }
                val partialFilePath = task.savedDir + File.separator + filename
                val partialFile = File(partialFilePath)
                if (partialFile.exists()) {
                    val request = buildRequest(task.url, task.savedDir, task.filename, task.headers, task.showNotification, task.openFileFromNotification, true, requiresStorageNotLow)
                    val newTaskId = request.id.toString()
                    result.success(newTaskId)
                    sendUpdateProgress(newTaskId, TaskStatus.RUNNING, task.progress)
                    TaskDao.updateTask(dbHelper,taskId, newTaskId, TaskStatus.RUNNING, task.progress, false)
                    WorkManager.getInstance(context).enqueue(request)
                } else {
                    result.error("invalid_data", "not found partial downloaded data, this task cannot be resumed", null)
                }
            } else {
                result.error("invalid_status", "only paused task can be resumed", null)
            }
        } else {
            result.error("invalid_task_id", "not found task corresponding to given task id", null)
        }
    }
    private fun pause(call: MethodCall, result: MethodChannel.Result) {
        val taskId = call.argument<String>("task_id")
        TaskDao.updateTask(dbHelper,taskId!!, true)
        WorkManager.getInstance(context).cancelWorkById(UUID.fromString(taskId))
        result.success(null)
    }

    private fun cancelAll(call: MethodCall, result: MethodChannel.Result) {
        WorkManager.getInstance(context).cancelAllWorkByTag(TAG)
        result.success(null)
    }

    private fun cancel(call: MethodCall, result: MethodChannel.Result) {
        val taskId = call.argument<String>("task_id")
        WorkManager.getInstance(context).cancelWorkById(UUID.fromString(taskId))
        result.success(null)
    }

    private fun queryRunningTask(call: MethodCall, result: MethodChannel.Result) {
        val tasks = TaskDao.queryAllTaskOfStatus(dbHelper,DownloadStatus.RUNNING)
        val array = ArrayList<Map<String, *>>()
        for (task in tasks) {
            val item = HashMap<String, Any>()
            item["task_id"] = task.taskId
            item["status"] = task.status
            item["progress"] = task.progress
            item["url"] = task.url
            item["file_name"] = task.filename
            item["saved_dir"] = task.savedDir
            item["time_created"] = task.timeCreated
            item["current_length"] = task.currentLength
            item["all_length"] = task.allLength
            array.add(item)
        }
        result.success(array)
    }
    private fun queryCompleteTask(call: MethodCall, result: MethodChannel.Result) {
        val tasks = TaskDao.queryAllTaskOfStatus(dbHelper,DownloadStatus.COMPLETE)
        val array = ArrayList<Map<String, *>>()
        for (task in tasks) {
            val item = HashMap<String, Any>()
            item["task_id"] = task.taskId
            item["status"] = task.status
            item["progress"] = task.progress
            item["url"] = task.url
            item["file_name"] = task.filename
            item["saved_dir"] = task.savedDir
            item["time_created"] = task.timeCreated
            item["current_length"] = task.currentLength
            item["all_length"] = task.allLength
            array.add(item)
        }
        result.success(array)
    }
    private fun loadTasks(call: MethodCall, result: MethodChannel.Result) {
        val tasks = TaskDao.queryAllTasks(dbHelper)
        val array = ArrayList<Map<String, *>>()
        for (task in tasks) {
            val item = HashMap<String, Any>()
            item["task_id"] = task.taskId
            item["status"] = task.status
            item["progress"] = task.progress
            item["url"] = task.url
            item["file_name"] = task.filename
            item["saved_dir"] = task.savedDir
            item["time_created"] = task.timeCreated
            item["current_length"] = task.currentLength
            item["all_length"] = task.allLength
            array.add(item)
        }
        result.success(array)
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
        TaskDao.insertOrUpdateNewTask(dbHelper,taskId, url, TaskStatus.ENQUEUED, 0, filename?:"获取中", savedDir, headers, showNotification, openFileFromNotification)
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