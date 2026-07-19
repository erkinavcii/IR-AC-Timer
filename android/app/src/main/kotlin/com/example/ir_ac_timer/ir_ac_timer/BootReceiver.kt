package com.example.ir_ac_timer.ir_ac_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import org.json.JSONObject

class BootReceiver : BroadcastReceiver() {
    private val TAG = "BootReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON" &&
            intent.action != "com.htc.intent.action.QUICKBOOT_POWERON") return

        Log.d(TAG, "Phone booted, restoring alarm...")

        val sharedPrefs = AppConstants.prefs(context)
        val taskJsonString = sharedPrefs.getString(AppConstants.KEY_ACTIVE_TASK, null)

        if (taskJsonString == null) {
            Log.d(TAG, "No active task to restore on boot.")
            return
        }

        try {
            val taskJson = JSONObject(taskJsonString)
            val mode = taskJson.optString("mode", "")
            val now = System.currentTimeMillis()

            when (mode) {
                AppConstants.MODE_RECURRING -> {
                    val h = taskJson.optInt("targetHour", 0)
                    val m = taskJson.optInt("targetMinute", 0)
                    AlarmScheduler.scheduleExactAlarm(context, ScheduleCalculator.nextDailyTrigger(now, h, m))
                    Log.d(TAG, "Restored recurring alarm on boot: $h:$m")
                }
                AppConstants.MODE_COUNTDOWN -> {
                    val oneTimeEpoch = taskJson.optLong("oneTimeEpochMillis", 0)
                    if (oneTimeEpoch > now) {
                        AlarmScheduler.scheduleExactAlarm(context, oneTimeEpoch)
                        Log.d(TAG, "Restored countdown alarm on boot.")
                    } else {
                        // Expired during reboot — silent skip
                        sharedPrefs.edit().remove(AppConstants.KEY_ACTIVE_TASK).apply()
                        Log.d(TAG, "Countdown expired during reboot. Cleaned up.")
                    }
                }
                AppConstants.MODE_CYCLE -> {
                    val intervalMinutes = taskJson.optInt("cycleIntervalMinutes", 30)
                    val endEpochMillis = taskJson.optLong("cycleEndEpochMillis", 0L)
                    val nextTrigger = ScheduleCalculator.cycleBootRestoreTrigger(now, intervalMinutes, endEpochMillis)

                    if (nextTrigger == null) {
                        // End time already passed
                        sharedPrefs.edit().remove(AppConstants.KEY_ACTIVE_TASK).apply()
                        Log.d(TAG, "Cycle end time passed during reboot. Cleaned up.")
                        return
                    }

                    taskJson.put("nextTriggerEpochMillis", nextTrigger)
                    sharedPrefs.edit().putString(AppConstants.KEY_ACTIVE_TASK, taskJson.toString()).apply()
                    AlarmScheduler.scheduleExactAlarm(context, nextTrigger)
                    if (endEpochMillis == 0L) {
                        NotificationHelper.showCycleNotification(context, intervalMinutes, nextTrigger)
                    }
                    Log.d(TAG, "Restored cycle alarm on boot. Next: $nextTrigger")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in BootReceiver: ${e.message}", e)
        }
    }
}
