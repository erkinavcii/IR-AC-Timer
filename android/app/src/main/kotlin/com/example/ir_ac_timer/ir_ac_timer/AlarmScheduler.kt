package com.example.ir_ac_timer.ir_ac_timer

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

/**
 * Single Source of Truth for scheduling and canceling background IR alarms.
 * Centralizes AlarmManager flags, PendingIntent creation, and the request
 * code to prevent synchronization bugs across MainActivity, AlarmReceiver,
 * and BootReceiver.
 */
object AlarmScheduler {
    private const val TAG = "AlarmScheduler"
    const val REQUEST_CODE = AppConstants.REQUEST_CODE_ALARM

    /** Shared immutable-update flags for every PendingIntent in the app. */
    fun pendingIntentFlags(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

    private fun alarmPendingIntent(context: Context): PendingIntent =
        PendingIntent.getBroadcast(
            context, REQUEST_CODE, Intent(context, AlarmReceiver::class.java), pendingIntentFlags()
        )

    fun scheduleExactAlarm(context: Context, triggerTimeMillis: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager service not found.")
            return
        }

        val pendingIntent = alarmPendingIntent(context)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTimeMillis, pendingIntent)
        }
        Log.d(TAG, "Scheduled exact alarm for epoch: $triggerTimeMillis")
    }

    fun cancelAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val pendingIntent = alarmPendingIntent(context)
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        Log.d(TAG, "Canceled alarm with REQUEST_CODE=$REQUEST_CODE")
    }
}
