package com.example.example
import com.example.example.MicrophoneService
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import live.videosdk.videosdk.VideoSDK;
import android.net.Uri


class MainActivity : FlutterActivity() {
private val CHANNEL = "com.example.example/channel"


          override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMicrophoneService" -> {
                    startMicrophoneService()
                    result.success("Service Started")
                }
                "stopMicrophoneService" -> {
                    stopMicrophoneService()
                    result.success("Service Stopped")
                }
                else -> result.notImplemented()
            }
        }
    }

        
    
        private fun startMicrophoneService() {
        val intent = Intent(this, MicrophoneService::class.java)
        startService(intent)
    }

    private fun stopMicrophoneService() {
        val intent = Intent(this, MicrophoneService::class.java)
        stopService(intent)
    }
}

