package me.xmcf.kodproject.flutterchannel.download

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.nio.file.Files.exists
import android.os.Environment.getExternalStorageDirectory
import android.text.TextUtils
import androidx.annotation.Nullable
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.net.HttpURLConnection
import java.net.URL
import io.flutter.util.PathUtils.getFilesDir
import me.xmcf.kodproject.R
import org.json.JSONException
import org.json.JSONObject
import vn.hunghd.flutterdownloader.DownloadStatus
import java.io.*
import java.net.URLDecoder


class DownloadTaskWorker(private val context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {

    companion object {

        const val PROGRESS_EVENT = "me.xmcf.kodproject.UPDATE_PROGRESS_EVENT"

        const val TAG = "DownloadTaskWorker"
        const val ARG_URL = "url"
        const val ARG_FILE_NAME = "file_name"
        const val ARG_SAVED_DIR = "saved_file"
        const val ARG_HEADERS = "headers"
        const val ARG_IS_RESUME = "is_resume"
        const val ARG_SHOW_NOTIFICATION = "show_notification"
        const val ARG_OPEN_FILE_FROM_NOTIFICATION = "open_file_from_notification"

        const val EXTRA_ID = "id"
        const val EXTRA_PROGRESS = "progress"
        const val EXTRA_STATUS = "status"

        const val TIMEOUT = 30 * 1000

    }

    private val builder: NotificationCompat.Builder by lazy {
        initNotificationBuild()
    }
    private var currentProgress = 0
    private var mPrimaryId: Int? = null


    override fun doWork(): Result {

        val downloadUrl = inputData.getString(ARG_URL)
        val fileName = inputData.getString(ARG_FILE_NAME)
        val saveDir = inputData.getString(ARG_SAVED_DIR)
        val headers = inputData.getString(ARG_HEADERS)
        val isResume = inputData.getBoolean(ARG_IS_RESUME, false)
        val showNotification = inputData.getBoolean(ARG_SHOW_NOTIFICATION, false)
        val clickToOpenDownloadedFile = inputData.getBoolean(ARG_OPEN_FILE_FROM_NOTIFICATION, false)

        Log.d(TAG, "DownloadWorker{url=$downloadUrl,filename=$fileName,savedDir=$saveDir,header=$headers,isResume=$isResume")
        return try {
            TaskDao.updateTask(TaskDbHelper.getInstance(context), id.toString(), TaskStatus.RUNNING, 0)
            startDownloadFile(downloadUrl!!, saveDir!!, fileName, headers, isResume)
            Result.success()
        } catch (e: Exception) {
            TaskDao.updateTask(TaskDbHelper.getInstance(context),id.toString(), TaskStatus.FAILED, currentProgress)
            Result.failure()
        }


    }

    private fun startDownloadFile(url: String, saveDir: String, fileName: String?, headers: String?, isBreakpointDownload: Boolean = false) {

        val startTime = System.currentTimeMillis()
        var currentUrl = url;
        var currentURL = URL(currentUrl)
        var httpUrlConnection: HttpURLConnection? = null


        //设置超时时间
        var responseCode: Int
        var location: String?
        val visited = HashMap<String, Int>()
        var outputStream:FileOutputStream? =null
        var inputStream:InputStream?=null
        var bfi:BufferedInputStream? =null
        try {
            loop@ while (true) {
                if (!visited.containsKey(currentUrl)) {
                    visited[currentUrl] = 1
                } else {
                    val times = visited[currentUrl] ?: 0
                    if (times > 3) {
                        throw IOException("Stuck in redirect loop")
                    }
                    visited[url] = times + 1
                }


                currentURL = URL(currentUrl)
                Log.d(TAG, "Open connection to $url")
                httpUrlConnection = currentURL.openConnection() as HttpURLConnection
                httpUrlConnection.also {
                    it.connectTimeout = TIMEOUT
                    it.readTimeout = TIMEOUT
                    //如果为 true，则协议自动执行重定向。
                    it.instanceFollowRedirects = false

                    //设置允许得到服务器的输入流,默认为true可以不用设置
                    it.doInput = true
                    //设置请求方法
                    it.requestMethod = "GET"
                    //设置请求的字符编码
                    it.setRequestProperty("Charset", "utf-8")

                    it.setRequestProperty("User-Agent", "Mozilla/5.0...")
                }

                // setup request headers if it is set
                if (headers != null) {
                    setupHeaders(httpUrlConnection, headers)
                }

                // try to continue downloading a file from its partial downloaded data.
                var downloadedBytes: Long = 0
                if (isBreakpointDownload && fileName != null) {
                    downloadedBytes = setupPartialDownloadedDataHeader(httpUrlConnection, fileName, saveDir)
                }
                httpUrlConnection.connect()
                responseCode = httpUrlConnection.responseCode
                when (responseCode) {
                    HttpURLConnection.HTTP_MOVED_PERM, HttpURLConnection.HTTP_MOVED_TEMP -> {
                        Log.d(TAG, "Response with redirection code")
                        location = URLDecoder.decode(httpUrlConnection.getHeaderField("Location"), "UTF-8")
                        val base = URL(url)
                        val next = URL(base, location)  // Deal with relative URLs
                        currentUrl = next.toString()
                        Log.d(TAG, "New url: $url")
                        continue@loop
                    }
                }

                break
            }



            if (responseCode == HttpURLConnection.HTTP_OK || (responseCode == HttpURLConnection.HTTP_PARTIAL && isBreakpointDownload) && !isStopped) {
                val contentType = httpUrlConnection!!.contentType
                //获取请求的内容总长度
                val contentLength = httpUrlConnection.contentLength
                Log.d(TAG, "Content-Type = $contentType")
                Log.d(TAG, "Content-Length = $contentLength")
                var currentFileName: String? = null
                if (!isBreakpointDownload && TextUtils.isEmpty(fileName)) {
                    // try to extract filename from HTTP headers if it is not given by user
                    if (fileName == null) {
                        val disposition = httpUrlConnection.getHeaderField("Content-Disposition")
                        Log.d(TAG, "Content-Disposition = " + disposition!!)
                        if (disposition != null && disposition.isNotEmpty()) {
                            val name = disposition!!.replaceFirst("(?i)^.*filename=\"?([^\"]+)\"?.*$".toRegex(), "$1")
                            currentFileName = URLDecoder.decode(name, "ISO-8859-1")
                        }
                        if (currentFileName == null || currentFileName.isEmpty()) {
                            currentFileName = url.substring(url.lastIndexOf("/") + 1)
                        }
                    }
                } else {
                    currentFileName = fileName
                }
                TaskDao.updateTask(TaskDbHelper.getInstance(context), id.toString(), currentFileName!!, contentType)
                val file = File(saveDir, currentFileName)
                //创建一个文件输出流
                outputStream = FileOutputStream(file, isBreakpointDownload)
                //得到服务器响应的输入流
                inputStream = httpUrlConnection.inputStream

                //创建缓冲输入流对象，相对于inputStream效率要高一些
                bfi = BufferedInputStream(inputStream)
                //此处的len表示每次循环读取的内容长度
                var len: Int
                //已经读取的总长度
                var readed = 0
                //bytes是用于存储每次读取出来的内容
                val bytes = ByteArray(1024)
                do {
                    len = bfi.read(bytes)
                    if (len == -1) {
                        break
                    }
                    readed += len
                    //通过文件输出流写入从服务器中读取的数据
                    outputStream.write(bytes, 0, len)
                    val progress = (readed.toFloat() *100/ contentLength).toInt()
                    updateNotification(currentFileName, DownloadStatus.RUNNING, progress, null)

                } while (true)
                val task = TaskDao.queryTask(TaskDbHelper.getInstance(context), id.toString())!!
                val progress = if (isStopped && task.resumable) currentProgress else 100
                val status = if (isStopped) if (task.resumable) DownloadStatus.PAUSED else DownloadStatus.CANCELED else DownloadStatus.COMPLETE
                TaskDao.updateTask(TaskDbHelper.getInstance(context), id.toString(),status,progress)
                updateNotification(currentFileName, status, progress, null)
                //关闭打开的流对象
                outputStream.close()
                inputStream.close()
                bfi.close()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            TaskDao.updateTask(TaskDbHelper.getInstance(context),id.toString(), TaskStatus.FAILED, currentProgress)
        } finally {
            bfi?.close()
            inputStream?.close()
            outputStream?.close()
            httpUrlConnection?.disconnect()
        }
    }


    private fun setupPartialDownloadedDataHeader(conn: HttpURLConnection, filename: String, savedDir: String): Long {
        val saveFilePath = savedDir + File.separator + filename
        val partialFile = File(saveFilePath)
        val downloadedBytes = partialFile.length()
        Log.d(TAG, "Resume download: Range: bytes=$downloadedBytes-")
        conn.setRequestProperty("Accept-Encoding", "identity")
        conn.setRequestProperty("Range", "bytes=$downloadedBytes-")
        conn.doInput = true
        return downloadedBytes
    }


    private fun setupHeaders(conn: HttpURLConnection, headers: String) {
        if (!TextUtils.isEmpty(headers)) {
            Log.d(TAG, "Headers = $headers")
            try {
                val json = JSONObject(headers)
                val it = json.keys()
                while (it.hasNext()) {
                    val key = it.next()
                    conn.setRequestProperty(key, json.getString(key))
                }
                conn.doInput = true
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        }
    }

    private fun sendProgress(status: Int, progress: Int) {
        if (progress == currentProgress) {
            return
        }
        currentProgress = progress
        val intent = Intent(PROGRESS_EVENT)
        intent.putExtra(EXTRA_ID, id.toString())
        intent.putExtra(EXTRA_STATUS, status)
        intent.putExtra(EXTRA_PROGRESS, progress)
        LocalBroadcastManager.getInstance(context).sendBroadcast(intent)
    }

    private fun initNotificationBuild(): NotificationCompat.Builder {
        // Make a channel if necessary
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Create the NotificationChannel, but only on API 26+ because
            // the NotificationChannel class is new and not in the support library

            val name = context.applicationInfo.loadLabel(context.packageManager)
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(DownloadChannel.DOWNLOADING.channelId, name, importance)
            channel.setSound(null, null)

            // Add the channel
            context.getSystemService(NotificationManager::class.java)?.createNotificationChannel(channel)
        }

        // Create the notification
        return NotificationCompat.Builder(context, DownloadChannel.DOWNLOADING.channelId)
                .setSmallIcon(R.mipmap.ic_download)
                .setAutoCancel(true)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
    }

    private fun updateNotification(fileName: String, status: Int, progress: Int, @Nullable intent: PendingIntent?) {
        builder.setContentTitle(fileName)
        builder.setContentIntent(intent)
        var shouldUpdate = false

        if (status == TaskStatus.RUNNING) {
            shouldUpdate = true
            builder.setContentText(if (progress == 0) "已开始" else "下载中")
                    .setProgress(100, progress, progress == 0)
            sendProgress(TaskStatus.RUNNING, progress)
        } else if (status == TaskStatus.CANCELED) {
            shouldUpdate = true
            builder.setContentText("已取消").setProgress(0, 0, false)
        } else if (status == TaskStatus.FAILED) {
            shouldUpdate = true
            builder.setContentText("出错").setProgress(0, 0, false)
        } else if (status == TaskStatus.PAUSED) {
            shouldUpdate = true
            builder.setContentText("暂停").setProgress(0, 0, false)
        } else if (status == TaskStatus.COMPLETE) {
            shouldUpdate = true
            builder.setContentText("完成").setProgress(0, 0, false)
        }

        // Show the notification
        if (shouldUpdate) {
            NotificationManagerCompat.from(context).notify(mPrimaryId
                    ?: getPrimaryId(), builder.build())
        }
    }

    private fun getPrimaryId(): Int {
        val task = TaskDao.queryTask(TaskDbHelper.getInstance(context), id.toString())
        return task!!.primaryId
    }
}