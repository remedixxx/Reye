package com.reye.app

import android.Manifest
import android.app.NotificationManager
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.system.exitProcess

class MainActivity : FlutterActivity() {
    private val notificationsChannel = "com.reye.app/android_notifications"
    private val appLifecycleChannel = "com.reye.app/app_lifecycle"
    private val screenEventsChannel = "com.reye.app/android_screen_events"
    private val notificationPermissionRequestCode = 202020
    private var pendingNotificationPermissionResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        applyReminderWindowFlags(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        applyReminderWindowFlags(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationsChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    NotificationHelper.createNotificationChannel(this)
                    result.success(null)
                }
                "requestPermissions" -> requestNotificationPermission(result)
                "isFullScreenIntentPermissionGranted" -> {
                    result.success(canUseFullScreenIntent())
                }
                "openFullScreenIntentSettings" -> {
                    result.success(openFullScreenIntentSettings())
                }
                "scheduleBreakReminder" -> {
                    val scheduledTimeMillis = call.argument<Long>("scheduledTimeMillis")
                    if (scheduledTimeMillis == null) {
                        result.error("missing_time", "scheduledTimeMillis is required", null)
                    } else {
                        NotificationHelper.scheduleBreakReminder(
                            this,
                            scheduledTimeMillis,
                            call.argument<String>("reminderTitle")
                                ?: getString(R.string.default_reminder_title),
                            call.argument<String>("reminderBody")
                                ?: getString(R.string.default_reminder_body),
                            call.argument<String>("countdownTitle") ?: getString(R.string.app_name),
                            call.argument<String>("countdownBody")
                                ?: getString(R.string.default_countdown_body),
                            call.argument<Boolean>("openAppOnBreakDue") ?: false,
                        )
                        result.success(null)
                    }
                }
                "cancelBreakReminder" -> {
                    NotificationHelper.cancelBreakReminder(this)
                    result.success(null)
                }
                "showImmediateBreakReminder" -> {
                    NotificationHelper.showBreakReminder(
                        this,
                        call.argument<String>("reminderTitle")
                            ?: getString(R.string.default_reminder_title),
                        call.argument<String>("reminderBody")
                            ?: getString(R.string.default_reminder_body),
                        call.argument<Boolean>("openAppOnBreakDue") ?: false,
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            appLifecycleChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "shutdownApp" -> {
                    NotificationHelper.cancelBreakReminder(this)
                    result.success(null)
                    window.decorView.post {
                        shutdownAppProcess()
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            screenEventsChannel,
        ).setStreamHandler(AndroidScreenEventStream(this))
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != notificationPermissionRequestCode) {
            return
        }

        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingNotificationPermissionResult?.success(granted)
        pendingNotificationPermissionResult = null
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success(true)
            return
        }

        if (checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) == PackageManager.PERMISSION_GRANTED) {
            result.success(true)
            return
        }

        pendingNotificationPermissionResult?.success(false)
        pendingNotificationPermissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            notificationPermissionRequestCode,
        )
    }

    private fun canUseFullScreenIntent(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return true
        }
        return getSystemService(NotificationManager::class.java).canUseFullScreenIntent()
    }

    private fun openFullScreenIntentSettings(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return true
        }
        return try {
            startActivity(
                Intent(
                    Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT,
                    Uri.parse("package:$packageName"),
                ),
            )
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun applyReminderWindowFlags(intent: Intent?) {
        if (intent?.getBooleanExtra("showReminderScreen", false) != true) {
            return
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON,
            )
        }
    }

    private fun shutdownAppProcess() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            finishAndRemoveTask()
        } else {
            @Suppress("DEPRECATION")
            finish()
        }
        Process.killProcess(Process.myPid())
        exitProcess(0)
    }
}
