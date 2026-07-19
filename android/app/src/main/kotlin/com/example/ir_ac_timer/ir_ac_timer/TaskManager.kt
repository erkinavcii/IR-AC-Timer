package com.example.ir_ac_timer.ir_ac_timer

import android.content.Context
import android.util.Log

/**
 * Cancels the active task from any entry point — MainActivity, the
 * notification Stop action, or the home-screen widget — without needing
 * an Activity.
 */
object TaskManager {
    private const val TAG = "TaskManager"

    fun cancel(context: Context) {
        AlarmScheduler.cancelAlarm(context)
        AppConstants.prefs(context).edit().remove(AppConstants.KEY_ACTIVE_TASK).apply()
        // Always attempt to dismiss any lingering notification
        NotificationHelper.cancelNotification(context)
        Log.d(TAG, "Task cancelled.")
    }
}
