package me.xmcf.kodproject.flutterchannel

import android.content.Context
import android.os.Environment
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.flutter.util.PathUtils

class FilePlugin{

    companion object {
        var CHANNEL = "plugin.xmcf.me/file_plugin"

        fun onMethodCall(context:Context,call: MethodCall, result: MethodChannel.Result) {
            when (call.method) {
                "getTemporaryDirectory" -> result.success(getPathProviderTemporaryDirectory(context))
                "getApplicationDocumentsDirectory" -> result.success(getPathProviderApplicationDocumentsDirectory(context))
                "getStorageDirectory" -> result.success(getPathProviderStorageDirectory(context))
                "getExternalStorageDirectory" -> result.success(getExternalStorageDirectory(context))
                "getApplicationSupportDirectory" -> {
                    result.success(getApplicationSupportDirectory(context))
                    result.notImplemented()
                }
                else -> result.notImplemented()
            }
        }

        private fun getPathProviderTemporaryDirectory(context:Context): String {
            return context.cacheDir.path
        }

        private fun getApplicationSupportDirectory(context:Context): String {
            return PathUtils.getFilesDir(context)
        }

        private fun getPathProviderApplicationDocumentsDirectory(context:Context): String {
            return PathUtils.getDataDirectory(context)
        }

        private fun getPathProviderStorageDirectory(context:Context): String? {
            val dir = context.getExternalFilesDir(null) ?: return null
            return dir.absolutePath
        }

        private fun getExternalStorageDirectory(context:Context): String? {
            if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
                //SD卡已装入
                val dir = Environment.getExternalStorageDirectory() ?:return  null
                return dir.absolutePath

            }
            return null
        }
    }


}