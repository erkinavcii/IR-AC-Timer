package com.example.ir_ac_timer.ir_ac_timer

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.Toast
import org.json.JSONArray

/**
 * Fired by the widget's "AC OFF" button: sends the selected profile's OFF
 * signal immediately (3× burst) and records a "manual_widget" stat, without
 * opening the app. Reads the profile straight from prefs since no Activity
 * or Flutter engine is running.
 */
class TransmitNowReceiver : BroadcastReceiver() {
    private val TAG = "TransmitNowReceiver"

    override fun onReceive(context: Context, intent: Intent) {
        val profile = selectedProfile(context)
        if (profile == null) {
            Log.e(TAG, "No selected profile / pattern to transmit.")
            return
        }
        val (pattern, frequency) = profile
        if (!hasIrEmitter(context)) {
            Toast.makeText(context, R.string.widget_no_ir, Toast.LENGTH_SHORT).show()
            return
        }
        IrTransmitter.transmitBurst(context, pattern, frequency)
        StatsStore.record(context, "manual_widget")
    }

    private fun hasIrEmitter(context: Context): Boolean {
        val ir = context.getSystemService(Context.CONSUMER_IR_SERVICE)
                as? android.hardware.ConsumerIrManager
        return ir != null && ir.hasIrEmitter()
    }

    /** (pattern, frequency) of the selected profile, or null. */
    private fun selectedProfile(context: Context): Pair<IntArray, Int>? {
        val prefs = AppConstants.prefs(context)
        val profilesJson = prefs.getString(AppConstants.KEY_DEVICE_PROFILES, null) ?: return null
        val selectedName = prefs.getString(AppConstants.KEY_SELECTED_PROFILE, null)
        return try {
            val arr = JSONArray(profilesJson)
            if (arr.length() == 0) return null
            // Prefer the selected profile; fall back to the first.
            var chosen = arr.getJSONObject(0)
            if (selectedName != null) {
                for (i in 0 until arr.length()) {
                    val p = arr.getJSONObject(i)
                    if (p.optString("name") == selectedName) {
                        chosen = p
                        break
                    }
                }
            }
            val patternArr = chosen.optJSONArray("pattern") ?: return null
            val pattern = IntArray(patternArr.length()) { patternArr.getInt(it) }
            if (pattern.isEmpty()) return null
            val frequency = chosen.optInt("frequency", AppConstants.DEFAULT_CARRIER_HZ)
            pattern to frequency
        } catch (e: Exception) {
            Log.e(TAG, "Failed to read selected profile: ${e.message}")
            null
        }
    }
}
