package com.example.ir_ac_timer.ir_ac_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

/**
 * Fired by the "Stop" action on the persistent cycle notification.
 * Cancels the active task (alarm + prefs + notification) without an
 * Activity. The in-app UI picks up the cleared task on its next 5s poll.
 */
class StopTaskReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("StopTaskReceiver", "Stop action received — cancelling task.")
        TaskManager.cancel(context)
    }
}
