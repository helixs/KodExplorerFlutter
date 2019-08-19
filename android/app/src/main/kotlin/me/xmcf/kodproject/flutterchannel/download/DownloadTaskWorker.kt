package me.xmcf.kodproject.flutterchannel.download

import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.nio.file.Files.exists
import android.os.Environment.getExternalStorageDirectory
import android.text.TextUtils
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import io.flutter.util.PathUtils.getFilesDir
import java.io.BufferedInputStream
import java.io.FileOutputStream


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

        private fun getDefaultFileName(httpURLConnectioned: HttpURLConnection): String {


            //得到链接地址中的file路径
            val urlFilePath = httpURLConnectioned.url.file
            //得到url地址总文件名 file的separatorChar参数表示文件分离符
            return urlFilePath.substring(urlFilePath.lastIndexOf(File.separatorChar) + 1)

        }
    }

    private val dbHelper by lazy { TaskDbHelper.getInstance(context) }

    override fun doWork(): Result {
        val context = applicationContext
        val taskDbHelper = TaskDbHelper.getInstance(context)

        val downloadUrl = inputData.getString(ARG_URL)
        val fileName = inputData.getString(ARG_FILE_NAME)
        val saveDir = inputData.getString(ARG_SAVED_DIR)
        val headers = inputData.getString(ARG_HEADERS)
        val isResume = inputData.getBoolean(ARG_IS_RESUME, false)
        val showNotification = inputData.getBoolean(ARG_SHOW_NOTIFICATION, false)
        val clickToOpenDownloadedFile = inputData.getBoolean(ARG_OPEN_FILE_FROM_NOTIFICATION, false)

        Log.d(TAG, "DownloadWorker{url=$downloadUrl,filename=$fileName,savedDir=$saveDir,header=$headers,isResume=$isResume")

        val taskInfo = TaskDao.queryTask(taskDbHelper, id.toString())
        val taskPrimaryId = taskInfo?.primaryId
        return try {
//            TaskDao.updateTask(taskDbHelper, id.toString(), TaskStatus.RUNNING, 0)
            startDownloadFile(downloadUrl!!,saveDir!!,fileName)
            Result.success()
        } catch (e: Exception) {
            Result.failure()
        }


    }

    private fun startDownloadFile(url: String, saveDir: String, fileName: String?) {

        val startTime = System.currentTimeMillis()
        val currentURL = URL(url)
        val httpUrlConnection = currentURL.openConnection() as HttpURLConnection
        //设置超时时间
        httpUrlConnection.also {
            it.connectTimeout = TIMEOUT
            //设置允许得到服务器的输入流,默认为true可以不用设置
            it.doInput = true
            //设置请求方法
            it.requestMethod = "GET"
            //设置请求的字符编码
            it.setRequestProperty("Charset", "utf-8")
        }

        httpUrlConnection.connect()
        val currentFileName =
                if (!TextUtils.isEmpty(fileName)) {
                    fileName
                } else {
                    getDefaultFileName(httpUrlConnection)
                }
        val file = File(saveDir, currentFileName)
        //创建一个文件输出流
        val outputStream = FileOutputStream(file)
        //得到链接的响应码 200为成功
        val responseCode = httpUrlConnection.responseCode
        if (responseCode == HttpURLConnection.HTTP_OK){
            //得到服务器响应的输入流
            val inputStream = httpUrlConnection.inputStream
            //获取请求的内容总长度
            val contentLength = httpUrlConnection.contentLength
            //创建缓冲输入流对象，相对于inputStream效率要高一些
            val bfi = BufferedInputStream(inputStream)
            //此处的len表示每次循环读取的内容长度
            var len: Int
            //已经读取的总长度
            var readed = 0
            //bytes是用于存储每次读取出来的内容
            val bytes = ByteArray(1024)
            do {
                len = bfi.read(bytes)
                if (len!=-1){
                    break
                }
                readed +=len
                //通过文件输出流写入从服务器中读取的数据
                outputStream.write(bytes, 0, len)
                val progress = (readed.toFloat()/contentLength).toInt()
                sendProgress(TaskStatus.RUNNING,progress)
            }while (true)
            //关闭打开的流对象
            outputStream.close()
            inputStream.close()
            bfi.close()
        }
    }

     private  fun  sendProgress(status:Int,progress:Int){
         val intent = Intent(PROGRESS_EVENT)
         intent.putExtra(EXTRA_ID, id.toString())
         intent.putExtra(EXTRA_STATUS, status)
         intent.putExtra(EXTRA_PROGRESS, progress)
         LocalBroadcastManager.getInstance(context).sendBroadcast(intent)
    }

}