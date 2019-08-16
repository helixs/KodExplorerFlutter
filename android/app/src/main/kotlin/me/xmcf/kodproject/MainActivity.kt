package me.xmcf.kodproject

import android.os.Bundle

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import me.xmcf.kodproject.flutterchannel.file.FilePlugin

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    regusterSelfPlugins()
  }
  private fun regusterSelfPlugins(){
    MethodChannel(flutterView, FilePlugin.CHANNEL).setMethodCallHandler { call, result ->
      FilePlugin.onMethodCall(applicationContext,call,result)
    }
  }
}
