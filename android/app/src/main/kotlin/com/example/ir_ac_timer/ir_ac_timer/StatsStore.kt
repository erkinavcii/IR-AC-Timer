package com.example.ir_ac_timer.ir_ac_timer

import android.content.Context
import android.util.Log
import org.json.JSONArray
import org.json.JSONObject

/**
 * Lightweight usage log: one {"t": epoch, "mode": mode} entry per actually
 * fired signal (scheduled alarms + widget taps — never manual test taps),
 * capped at the newest [MAX_EVENTS]. Stored as a JSON array in prefs.
 */
object StatsStore {
    private const val TAG = "StatsStore"
    private const val MAX_EVENTS = 200

    fun record(context: Context, mode: String) {
        try {
            val prefs = AppConstants.prefs(context)
            val raw = prefs.getString(AppConstants.KEY_STATS_EVENTS, null)
            val arr = if (raw != null) JSONArray(raw) else JSONArray()
            arr.put(JSONObject().apply {
                put("t", System.currentTimeMillis())
                put("mode", mode)
            })
            // Trim to the newest MAX_EVENTS
            val trimmed = if (arr.length() > MAX_EVENTS) {
                JSONArray().also { out ->
                    for (i in arr.length() - MAX_EVENTS until arr.length()) {
                        out.put(arr.get(i))
                    }
                }
            } else {
                arr
            }
            prefs.edit().putString(AppConstants.KEY_STATS_EVENTS, trimmed.toString()).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to record stat: ${e.message}")
        }
    }

    /** Returns the raw JSON array string, or "[]" when empty. */
    fun getRaw(context: Context): String =
        AppConstants.prefs(context).getString(AppConstants.KEY_STATS_EVENTS, null) ?: "[]"

    fun reset(context: Context) {
        AppConstants.prefs(context).edit().remove(AppConstants.KEY_STATS_EVENTS).apply()
    }
}
