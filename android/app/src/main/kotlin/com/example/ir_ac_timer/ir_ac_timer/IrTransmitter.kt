package com.example.ir_ac_timer.ir_ac_timer

import android.content.Context
import android.hardware.ConsumerIrManager
import android.util.Log

/**
 * Single place that talks to ConsumerIrManager, shared by the foreground
 * UI (MainActivity) and background receivers (AlarmReceiver, widget).
 */
object IrTransmitter {
    private const val TAG = "IrTransmitter"

    fun transmit(
        context: Context,
        pattern: IntArray,
        frequencyHz: Int = AppConstants.DEFAULT_CARRIER_HZ
    ): Boolean {
        val irManager = context.getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        if (irManager == null || !irManager.hasIrEmitter()) {
            Log.e(TAG, "No IR emitter found.")
            return false
        }
        return try {
            irManager.transmit(frequencyHz, pattern)
            Log.d(TAG, "IR transmitted (${pattern.size} marks @ ${frequencyHz}Hz).")
            true
        } catch (e: Exception) {
            Log.e(TAG, "IR transmit failed: ${e.message}")
            false
        }
    }
}
