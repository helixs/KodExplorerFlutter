package me.xmcf.kodproject.flutterchannel.download

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import java.io.File

@Synchronized
fun getOpenFileIntent(context: Context, path: String, contentType: String): Intent {
    val file = File(path)
    val intent = Intent(Intent.ACTION_VIEW)

    if (Build.VERSION.SDK_INT >= 24) {
        val uri = FileProvider.getUriForFile(
                context,
                context.packageName + ".fileprovider", file)
        intent.setDataAndType(uri, contentType)
    } else {
        intent.setDataAndType(Uri.fromFile(file), contentType)
    }

    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    return intent
}
@Synchronized
fun validateIntent(context: Context, intent: Intent): Boolean {
    val manager = context.packageManager
    val infos = manager.queryIntentActivities(intent, 0)
    return if (infos.size > 0) {
        //Then there is an Application(s) can handle this intent
        true
    } else {
        //No Application can handle this intent
        false
    }
}
