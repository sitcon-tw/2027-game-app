package org.sitcon.game101010

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val context = applicationContext
        MethodChannel(
            messenger,
            "org.sitcon/device_sessions",
            StandardMethodCodec.INSTANCE,
            messenger.makeBackgroundTaskQueue()
        ).setMethodCallHandler { call, result ->
            if (call.method != "flush") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            // flutter_secure_storage uses apply(); force a disk commit before
            // the app sends an enrollment or transfer credential to the API.
            val flushed = listOf("FlutterSecureKeyStorage", "FlutterSecureStorage").all { file ->
                val preferences = context.getSharedPreferences(file, Context.MODE_PRIVATE)
                val barrier = "sitcon-device-session-flush"
                preferences.edit().putBoolean(barrier, !preferences.getBoolean(barrier, false)).commit()
            }
            if (flushed) result.success(null) else result.error("storage", null, null)
        }
    }
}
