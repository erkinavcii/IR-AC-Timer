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

    /**
     * Sends the same pattern [repeats] times with [gapMs] between sends to
     * improve reliability when the phone is not aimed perfectly. Used only
     * for scheduled fires (AlarmReceiver/widget), not manual test taps.
     *
     * OFF frames are full-state and idempotent, so repeating is safe. Total
     * time (~1.2s for 3×500ms) stays well under the BroadcastReceiver
     * main-thread budget, so no goAsync() is needed.
     *
     * @return true if at least one send succeeded.
     */
    fun transmitBurst(
        context: Context,
        pattern: IntArray,
        frequencyHz: Int = AppConstants.DEFAULT_CARRIER_HZ,
        repeats: Int = 3,
        gapMs: Long = 500
    ): Boolean {
        var anySucceeded = false
        for (i in 0 until repeats) {
            if (transmit(context, pattern, frequencyHz)) anySucceeded = true
            if (i < repeats - 1) {
                try {
                    Thread.sleep(gapMs)
                } catch (e: InterruptedException) {
                    Log.w(TAG, "Burst interrupted: ${e.message}")
                    break
                }
            }
        }
        return anySucceeded
    }
}
