package com.reye.app

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build

object NotificationHelper {
    private const val reminderChannelId = "reye_break_reminders"
    private const val countdownChannelId = "reye_timer_countdown"
    private const val reminderNotificationId = 202020
    private const val countdownNotificationId = 202021
    private const val requestCode = 202020
    private const val extraReminderTitle = "reminderTitle"
    private const val extraReminderBody = "reminderBody"
    private const val extraOpenAppOnBreakDue = "openAppOnBreakDue"

    fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return
        }

        val notificationManager = context.getSystemService(NotificationManager::class.java)
        if (notificationManager.getNotificationChannel(reminderChannelId) == null) {
            val reminderChannel = NotificationChannel(
                reminderChannelId,
                context.getString(R.string.reminder_channel_name),
                NotificationManager.IMPORTANCE_HIGH,
            ).apply {
                description = context.getString(R.string.reminder_channel_description)
            }
            notificationManager.createNotificationChannel(reminderChannel)
        }

        if (notificationManager.getNotificationChannel(countdownChannelId) == null) {
            val countdownChannel = NotificationChannel(
                countdownChannelId,
                context.getString(R.string.countdown_channel_name),
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = context.getString(R.string.countdown_channel_description)
                setSound(null, null)
            }
            notificationManager.createNotificationChannel(countdownChannel)
        }
    }

    fun scheduleBreakReminder(
        context: Context,
        scheduledTimeMillis: Long,
        reminderTitle: String,
        reminderBody: String,
        countdownTitle: String,
        countdownBody: String,
        openAppOnBreakDue: Boolean,
    ) {
        createNotificationChannel(context)
        cancelScheduledAlarm(context)
        showCountdownNotification(context, scheduledTimeMillis, countdownTitle, countdownBody)

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.set(
            AlarmManager.RTC_WAKEUP,
            maxOf(scheduledTimeMillis, System.currentTimeMillis() + 1_000L),
            reminderPendingIntent(context, reminderTitle, reminderBody, openAppOnBreakDue),
        )
    }

    fun cancelBreakReminder(context: Context) {
        cancelScheduledAlarm(context)

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(countdownNotificationId)
        notificationManager.cancel(reminderNotificationId)
    }

    fun showBreakReminder(
        context: Context,
        title: String = context.getString(R.string.default_reminder_title),
        body: String = context.getString(R.string.default_reminder_body),
        openAppOnBreakDue: Boolean = false,
    ) {
        if (!canPostNotifications(context)) {
            if (openAppOnBreakDue) {
                openApp(context)
            }
            return
        }

        createNotificationChannel(context)
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancel(countdownNotificationId)
        notificationManager.notify(
            reminderNotificationId,
            buildReminderNotification(context, title, body, openAppOnBreakDue),
        )
        if (openAppOnBreakDue) {
            openApp(context)
        }
    }

    private fun canPostNotifications(context: Context): Boolean {
        return Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU ||
            context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun showCountdownNotification(
        context: Context,
        scheduledTimeMillis: Long,
        title: String,
        body: String,
    ) {
        if (!canPostNotifications(context)) {
            return
        }

        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(
            countdownNotificationId,
            buildCountdownNotification(context, scheduledTimeMillis, title, body),
        )
    }

    private fun buildReminderNotification(
        context: Context,
        title: String,
        body: String,
        openAppOnBreakDue: Boolean,
    ): Notification {
        val launchIntent = reminderLaunchIntent(context)

        val contentIntent = PendingIntent.getActivity(
            context,
            requestCode,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, reminderChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        builder
            .setSmallIcon(R.drawable.ic_stat_reye)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(contentIntent)
            .setAutoCancel(true)
            .setCategory(Notification.CATEGORY_ALARM)
            .setPriority(Notification.PRIORITY_HIGH)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setShowWhen(true)

        if (openAppOnBreakDue && canUseFullScreenIntent(context)) {
            val fullScreenIntent = PendingIntent.getActivity(
                context,
                requestCode + 2,
                reminderLaunchIntent(context),
                PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
            )
            builder.setFullScreenIntent(fullScreenIntent, true)
        }

        return builder.build()
    }

    private fun buildCountdownNotification(
        context: Context,
        scheduledTimeMillis: Long,
        title: String,
        body: String,
    ): Notification {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        launchIntent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)

        val contentIntent = PendingIntent.getActivity(
            context,
            requestCode + 1,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, countdownChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        builder
            .setSmallIcon(R.drawable.ic_stat_reye)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(contentIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setShowWhen(true)
            .setWhen(scheduledTimeMillis)
            .setUsesChronometer(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder.setChronometerCountDown(true)
        }

        @Suppress("DEPRECATION")
        builder
            .setDefaults(0)
            .setSound(null)
            .setVibrate(null)

        return builder.build()
    }

    private fun cancelScheduledAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.cancel(reminderPendingIntent(context))
    }

    private fun reminderPendingIntent(
        context: Context,
        title: String = "Time for an eye break",
        body: String = "Look at something far away for 20 seconds. Your eyes will thank you.",
        openAppOnBreakDue: Boolean = false,
    ): PendingIntent {
        val intent = Intent(context, BreakReminderReceiver::class.java).apply {
            putExtra(extraReminderTitle, title)
            putExtra(extraReminderBody, body)
            putExtra(extraOpenAppOnBreakDue, openAppOnBreakDue)
        }
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or immutableFlag(),
        )
    }

    private fun immutableFlag(): Int {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE
        } else {
            0
        }
    }

    private fun canUseFullScreenIntent(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            return true
        }
        return context
            .getSystemService(NotificationManager::class.java)
            .canUseFullScreenIntent()
    }

    fun reminderTitleFrom(intent: Intent): String {
        return intent.getStringExtra(extraReminderTitle) ?: "Time for an eye break"
    }

    fun reminderBodyFrom(intent: Intent): String {
        return intent.getStringExtra(extraReminderBody)
            ?: "Look at something far away for 20 seconds. Your eyes will thank you."
    }

    fun shouldOpenAppFrom(intent: Intent): Boolean {
        return intent.getBooleanExtra(extraOpenAppOnBreakDue, false)
    }

    private fun openApp(context: Context) {
        try {
            context.startActivity(reminderLaunchIntent(context))
        } catch (_: Exception) {
            // Android may block background activity launches. In that case the
            // full-screen notification remains the supported delivery path.
        }
    }

    private fun reminderLaunchIntent(context: Context): Intent {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        launchIntent.addFlags(
            Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_CLEAR_TOP or
                Intent.FLAG_ACTIVITY_SINGLE_TOP,
        )
        launchIntent.putExtra("showReminderScreen", true)
        return launchIntent
    }
}
