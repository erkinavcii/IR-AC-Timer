package com.example.ir_ac_timer.ir_ac_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import org.json.JSONObject
import android.app.AlarmManager
import android.app.PendingIntent
import android.os.Build
import java.util.Calendar

class BootReceiver : BroadcastReceiver() {
    private val TAG = "BootReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON" &&
            intent.action != "com.htc.intent.action.QUICKBOOT_POWERON") return

        Log.d(TAG, "Phone booted, restoring alarm...")

        val sharedPrefs = context.getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
        val taskJsonString = sharedPrefs.getString("active_task", null)

        if (taskJsonString == null) {
            Log.d(TAG, "No active task to restore on boot.")
            return
        }

        try {
            val taskJson = JSONObject(taskJsonString)
            val mode = taskJson.optString("mode", "")

            when (mode) {
                "recurring" -> {
                    val h = taskJson.optInt("targetHour", 0)
                    val m = taskJson.optInt("targetMinute", 0)
                    val calendar = Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, h)
                        set(Calendar.MINUTE, m)
                        set(Calendar.SECOND, 0)
                        set(Calendar.MILLISECOND, 0)
                    }
                    if (calendar.timeInMillis <= System.currentTimeMillis()) {
                        calendar.add(Calendar.DAY_OF_YEAR, 1)
                    }
                    scheduleAlarm(context, calendar.timeInMillis)
                    Log.d(TAG, "Restored recurring alarm on boot: $h:$m")
                }
                "countdown" -> {
                    val oneTimeEpoch = taskJson.optLong("oneTimeEpochMillis", 0)
                    val now = System.currentTimeMillis()
                    if (oneTimeEpoch > now) {
                        scheduleAlarm(context, oneTimeEpoch)
                        Log.d(TAG, "Restored countdown alarm on boot.")
                    } else {
                        // Expired during reboot — silent skip
                        sharedPrefs.edit().remove("active_task").apply()
                        Log.d(TAG, "Countdown expired during reboot. Cleaned up.")
                    }
                }
                "cycle" -> {
                    val intervalMinutes = taskJson.optInt("cycleIntervalMinutes", 30)
                    val endEpochMillis = taskJson.optLong("cycleEndEpochMillis", 0L)
                    val now = System.currentTimeMillis()

                    if (endEpochMillis != 0L && now >= endEpochMillis) {
                        // End time already passed
                        sharedPrefs.edit().remove("active_task").apply()
                        Log.d(TAG, "Cycle end time passed during reboot. Cleaned up.")
                        return
                    }

                    // Schedule next trigger from now
                    val nextTrigger = now + intervalMinutes * 60 * 1000L
                    val adjustedNext = if (endEpochMillis != 0L && nextTrigger >= endEpochMillis) endEpochMillis else nextTrigger
                    taskJson.put("nextTriggerEpochMillis", adjustedNext)
                    sharedPrefs.edit().putString("active_task", taskJson.toString()).apply()
                    scheduleAlarm(context, adjustedNext)
                    Log.d(TAG, "Restored cycle alarm on boot. Next: $adjustedNext")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in BootReceiver: ${e.message}", e)
        }
    }

    private fun scheduleAlarm(context: Context, triggerTime: Long) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val alarmIntent = Intent(context, AlarmReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getBroadcast(context, 1001, alarmIntent, flags)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent)
        }
    }
}
