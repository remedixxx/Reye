package com.reye.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class BreakReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        NotificationHelper.showBreakReminder(
            context,
            NotificationHelper.reminderTitleFrom(intent),
            NotificationHelper.reminderBodyFrom(intent),
            NotificationHelper.shouldOpenAppFrom(intent),
        )
    }
}
