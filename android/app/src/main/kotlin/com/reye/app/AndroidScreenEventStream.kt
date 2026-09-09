package com.reye.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.plugin.common.EventChannel

class AndroidScreenEventStream(private val context: Context) : EventChannel.StreamHandler {
    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (events == null || receiver != null) {
            return
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    Intent.ACTION_SCREEN_OFF -> events.success("screenOff")
                    Intent.ACTION_SCREEN_ON -> events.success("screenOn")
                }
            }
        }

        context.applicationContext.registerReceiver(
            receiver,
            IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(Intent.ACTION_SCREEN_ON)
            },
        )
    }

    override fun onCancel(arguments: Any?) {
        receiver?.let {
            runCatching { context.applicationContext.unregisterReceiver(it) }
        }
        receiver = null
    }
}
