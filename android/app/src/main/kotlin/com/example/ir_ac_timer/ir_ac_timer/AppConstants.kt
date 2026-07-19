package com.example.ir_ac_timer.ir_ac_timer

import android.content.Context
import android.content.SharedPreferences

/**
 * Single Source of Truth for SharedPreferences names/keys, task modes and
 * IR defaults. MainActivity, AlarmReceiver, BootReceiver and the widget all
 * read the same prefs file — a typo in one literal silently breaks
 * reboot-restore, so every key lives here.
 */
object AppConstants {
    const val PREFS_NAME = "ir_ac_timer_prefs"

    const val KEY_ACTIVE_TASK = "active_task"
    const val KEY_DEVICE_PROFILES = "device_profiles"
    const val KEY_SELECTED_PROFILE = "selected_profile_name"
    const val KEY_LANGUAGE = "app_language"
    const val KEY_STATS_EVENTS = "stats_events"

    const val MODE_COUNTDOWN = "countdown"
    const val MODE_RECURRING = "recurring"
    const val MODE_CYCLE = "cycle"

    const val DEFAULT_CARRIER_HZ = 38000
    const val DEFAULT_LANGUAGE = "tr"

    // PendingIntent request codes — keep distinct (1002 is the notification id)
    const val REQUEST_CODE_ALARM = 1001
    const val REQUEST_CODE_STOP_ACTION = 1003
    const val REQUEST_CODE_WIDGET_TRANSMIT = 1004

    fun prefs(context: Context): SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
