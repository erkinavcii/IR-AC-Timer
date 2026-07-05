package com.example.ir_ac_timer.ir_ac_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.hardware.ConsumerIrManager
import android.util.Log
import org.json.JSONObject
import android.os.Build
import java.util.Calendar

class AlarmReceiver : BroadcastReceiver() {
    private val TAG = "AlarmReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        Log.d(TAG, "Alarm triggered!")

        val sharedPrefs = context.getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
        val taskJsonString = sharedPrefs.getString("active_task", null)

        if (taskJsonString == null) {
            Log.d(TAG, "No active task found in SharedPreferences.")
            return
        }

        try {
            val taskJson = JSONObject(taskJsonString)
            val mode = taskJson.optString("mode", "")
            val patternString = taskJson.optString("pattern", "")

            // Transmit IR signal
            if (patternString.isNotEmpty()) {
                val pattern = patternString.split(",").map { it.trim().toInt() }.toIntArray()
                transmitIr(context, pattern)
            } else {
                Log.e(TAG, "IR Pattern is empty!")
            }

            when (mode) {
                "recurring" -> {
                    val targetHour = taskJson.optInt("targetHour", 0)
                    val targetMinute = taskJson.optInt("targetMinute", 0)
                    rescheduleNextDay(context, targetHour, targetMinute)
                }

                "cycle" -> {
                    val intervalMinutes = taskJson.optInt("cycleIntervalMinutes", 30)
                    val endEpochMillis = taskJson.optLong("cycleEndEpochMillis", 0L)
                    val now = System.currentTimeMillis()
                    val nextTrigger = now + intervalMinutes * 60 * 1000L

                    if (endEpochMillis == 0L || nextTrigger < endEpochMillis) {
                        // Still within window — reschedule
                        taskJson.put("nextTriggerEpochMillis", nextTrigger)
                        sharedPrefs.edit().putString("active_task", taskJson.toString()).apply()
                        scheduleSingleAlarm(context, nextTrigger)

                        // Keep persistent notification updated for indefinite cycles
                        if (endEpochMillis == 0L) {
                            NotificationHelper.showCycleNotification(context, intervalMinutes, nextTrigger)
                        }

                        Log.d(TAG, "Cycle rescheduled: next at ${java.util.Date(nextTrigger)}")
                    } else {
                        // End time reached — clean up
                        sharedPrefs.edit().remove("active_task").apply()
                        NotificationHelper.cancelNotification(context)
                        Log.d(TAG, "Cycle complete: end time reached")
                    }
                }

                "countdown" -> {
                    // One-time — clear
                    sharedPrefs.edit().remove("active_task").apply()
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in AlarmReceiver: ${e.message}", e)
        }
    }

    private fun transmitIr(context: Context, pattern: IntArray) {
        val irManager = context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        if (irManager != null && irManager.hasIrEmitter()) {
            try {
                irManager.transmit(38000, pattern)
                Log.d(TAG, "IR transmitted successfully.")
            } catch (e: Exception) {
                Log.e(TAG, "IR transmit failed: ${e.message}")
            }
        } else {
            Log.e(TAG, "No IR emitter found.")
        }
    }

    private fun rescheduleNextDay(context: Context, hour: Int, minute: Int) {
        val cal = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
            add(Calendar.DAY_OF_YEAR, 1)
        }
        scheduleSingleAlarm(context, cal.timeInMillis)
    }

    fun scheduleSingleAlarm(context: Context, triggerTime: Long) {
        AlarmScheduler.scheduleExactAlarm(context, triggerTime)
    }
}
