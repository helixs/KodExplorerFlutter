package me.xmcf.kodproject.flutterchannel.download

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class DownloadTaskWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {
    private val dbHelper by lazy { TaskDbHelper.getInstance(context) }

    override fun doWork(): Result {
        val context = applicationContext
        return Result.failure()
    }

}