package me.xmcf.kodproject

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import me.xmcf.kodproject.flutterchannel.download.DownloadPlugin
import me.xmcf.kodproject.flutterchannel.file.FilePlugin

class MainActivity: FlutterActivity() {

  private lateinit var downloadPlugin: DownloadPlugin
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    regusterSelfPlugins()
  }
  private fun regusterSelfPlugins(){
    MethodChannel(flutterView, FilePlugin.CHANNEL).setMethodCallHandler { call, result ->
      FilePlugin.onMethodCall(applicationContext,call,result)
    }
    downloadPlugin = DownloadPlugin.registerWith(this,flutterView)
  }

  override fun onResume() {
    super.onResume()
    downloadPlugin.onResume()
  }
  override fun onPause() {
    super.onPause()
    downloadPlugin.onPause()
  }
}
