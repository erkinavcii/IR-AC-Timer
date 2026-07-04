package com.example.ir_ac_timer.ir_ac_timer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Helper object for managing the persistent cycle notification.
 *
 * Shown only when an INDEFINITE cycle (no end time) is active,
 * so the user always has a visible reminder + quick-cancel entry
 * in the notification shade.
 */
object NotificationHelper {
    const val CHANNEL_ID = "ir_ac_cycle_channel"
    const val NOTIFICATION_ID = 1002

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "AC Döngü Zamanlayıcı",
                NotificationManager.IMPORTANCE_LOW   // Silent but visible
            ).apply {
                description = "Sonsuz döngü aktif olduğunda gösterilir"
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    fun showCycleNotification(context: Context, intervalMin: Int, nextTriggerEpoch: Long) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Tap notification → open app
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val openPendingIntent = PendingIntent.getActivity(context, 0, openIntent, flags)

        // Format next trigger time
        val nextTime = java.text.SimpleDateFormat("HH:mm", java.util.Locale.getDefault())
            .format(java.util.Date(nextTriggerEpoch))

        val notification = buildNotification(context, intervalMin, nextTime, openPendingIntent)
        nm.notify(NOTIFICATION_ID, notification)
    }

    private fun buildNotification(
        context: Context,
        intervalMin: Int,
        nextTime: String,
        contentIntent: PendingIntent
    ): Notification {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("🔁 AC Timer — Sonsuz Döngü Aktif")
                .setContentText("Her ${intervalMin}dk'da bir sinyal · Sonraki: $nextTime")
                .setSubText("Durdurmak için dokunun")
                .setOngoing(true)
                .setShowWhen(false)
                .setContentIntent(contentIntent)
                .build()
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
                .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
                .setContentTitle("🔁 AC Timer — Sonsuz Döngü Aktif")
                .setContentText("Her ${intervalMin}dk'da bir sinyal · Sonraki: $nextTime")
                .setOngoing(true)
                .setShowWhen(false)
                .setContentIntent(contentIntent)
                .build()
        }
    }

    fun cancelNotification(context: Context) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
    }
}
