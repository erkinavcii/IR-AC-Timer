package com.example.ir_ac_timer.ir_ac_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import org.json.JSONObject

class AlarmReceiver : BroadcastReceiver() {
    private val TAG = "AlarmReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm triggered!")

        val sharedPrefs = AppConstants.prefs(context)
        val taskJsonString = sharedPrefs.getString(AppConstants.KEY_ACTIVE_TASK, null)

        if (taskJsonString == null) {
            Log.d(TAG, "No active task found in SharedPreferences.")
            return
        }

        try {
            val taskJson = JSONObject(taskJsonString)
            val mode = taskJson.optString("mode", "")
            val patternString = taskJson.optString("pattern", "")

            // Transmit IR signal first — a reschedule failure must never skip the send
            if (patternString.isNotEmpty()) {
                val pattern = patternString.split(",").map { it.trim().toInt() }.toIntArray()
                val frequency = taskJson.optInt("frequency", AppConstants.DEFAULT_CARRIER_HZ)
                // 3× redundant burst on scheduled fires for reliability
                IrTransmitter.transmitBurst(context, pattern, frequency)
                StatsStore.record(context, mode)
            } else {
                Log.e(TAG, "IR Pattern is empty!")
            }

            when (mode) {
                AppConstants.MODE_RECURRING -> {
                    val targetHour = taskJson.optInt("targetHour", 0)
                    val targetMinute = taskJson.optInt("targetMinute", 0)
                    val nextTrigger = ScheduleCalculator.nextDailyTrigger(
                        System.currentTimeMillis(), targetHour, targetMinute, forceTomorrow = true
                    )
                    AlarmScheduler.scheduleExactAlarm(context, nextTrigger)
                }

                AppConstants.MODE_CYCLE -> {
                    val intervalMinutes = taskJson.optInt("cycleIntervalMinutes", 30)
                    val endEpochMillis = taskJson.optLong("cycleEndEpochMillis", 0L)
                    val nextTrigger = ScheduleCalculator.cycleNextTrigger(
                        System.currentTimeMillis(), intervalMinutes, endEpochMillis
                    )

                    if (nextTrigger != null) {
                        // Still within window — reschedule
                        taskJson.put("nextTriggerEpochMillis", nextTrigger)
                        sharedPrefs.edit().putString(AppConstants.KEY_ACTIVE_TASK, taskJson.toString()).apply()
                        AlarmScheduler.scheduleExactAlarm(context, nextTrigger)

                        // Keep persistent notification updated for indefinite cycles
                        if (endEpochMillis == 0L) {
                            NotificationHelper.showCycleNotification(context, intervalMinutes, nextTrigger)
                        }

                        Log.d(TAG, "Cycle rescheduled: next at ${java.util.Date(nextTrigger)}")
                    } else {
                        // End time reached — clean up
                        sharedPrefs.edit().remove(AppConstants.KEY_ACTIVE_TASK).apply()
                        NotificationHelper.cancelNotification(context)
                        Log.d(TAG, "Cycle complete: end time reached")
                    }
                }

                AppConstants.MODE_COUNTDOWN -> {
                    // One-time — clear
                    sharedPrefs.edit().remove(AppConstants.KEY_ACTIVE_TASK).apply()
                }
            }

            // Reflect the new next-trigger (or cleared task) on the widget
            AcTimerWidgetProvider.refresh(context)
        } catch (e: Exception) {
            Log.e(TAG, "Error in AlarmReceiver: ${e.message}", e)
        }
    }
}
