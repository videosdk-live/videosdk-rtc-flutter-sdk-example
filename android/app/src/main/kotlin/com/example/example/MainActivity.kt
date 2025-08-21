package com.example.example
import com.example.example.ForegroundService
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import android.net.Uri

class MainActivity : FlutterActivity() {
private val CHANNEL = "com.example.example/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startMicrophoneService" -> {
                    startService(Intent(this, ForegroundService::class.java).apply {
                        action = ForegroundService.ACTION_START
                    })
                    result.success(null)
                }
                "stopMicrophoneService" -> {
                    startService(Intent(this, ForegroundService::class.java).apply {
                        action = ForegroundService.ACTION_STOP
                    })
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}