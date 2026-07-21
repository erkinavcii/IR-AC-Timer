package com.example.ir_ac_timer.ir_ac_timer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Build
import java.util.Locale

/**
 * Helper object for managing the persistent cycle notification.
 *
 * Shown only when an INDEFINITE cycle (no end time) is active, so the user
 * always has a visible reminder + a one-tap Stop action in the shade.
 *
 * Strings are resolved against the in-app language preference (not the
 * device locale) so background re-posts from AlarmReceiver/BootReceiver —
 * which run with no Flutter engine — still match what the user picked.
 */
object NotificationHelper {
    const val CHANNEL_ID = "ir_ac_cycle_channel"
    const val NOTIFICATION_ID = 1002

    /** A Context whose resources resolve to the saved in-app language. */
    private fun localizedContext(context: Context): Context {
        val lang = AppConstants.prefs(context)
            .getString(AppConstants.KEY_LANGUAGE, AppConstants.DEFAULT_LANGUAGE)
            ?: AppConstants.DEFAULT_LANGUAGE
        val config = Configuration(context.resources.configuration).apply {
            setLocale(Locale(lang))
        }
        return context.createConfigurationContext(config)
    }

    fun createChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val loc = localizedContext(context)
            val channel = NotificationChannel(
                CHANNEL_ID,
                loc.getString(R.string.cycle_channel_name),
                NotificationManager.IMPORTANCE_LOW   // Silent but visible
            ).apply {
                description = loc.getString(R.string.cycle_channel_desc)
                setShowBadge(false)
                enableLights(false)
                enableVibration(false)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    fun showCycleNotification(context: Context, intervalMin: Int, nextTriggerEpoch: Long) {
        val loc = localizedContext(context)
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Refresh the channel so its localized name/description follow a
        // mid-session language change.
        createChannel(context)

        // Tap notification → open app
        val openIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val openPendingIntent =
            PendingIntent.getActivity(context, 0, openIntent, AlarmScheduler.pendingIntentFlags())

        // Stop action → cancel task without opening the app
        val stopIntent = Intent(context, StopTaskReceiver::class.java)
        val stopPendingIntent = PendingIntent.getBroadcast(
            context, AppConstants.REQUEST_CODE_STOP_ACTION, stopIntent,
            AlarmScheduler.pendingIntentFlags()
        )

        val nextTime = java.text.SimpleDateFormat("HH:mm", Locale.getDefault())
            .format(java.util.Date(nextTriggerEpoch))
        val title = loc.getString(R.string.cycle_notif_title)
        val text = loc.getString(R.string.cycle_notif_text, intervalMin, nextTime)
        val stopLabel = loc.getString(R.string.cycle_notif_stop)

        val notification = buildNotification(
            context, title, text, stopLabel, openPendingIntent, stopPendingIntent
        )
        nm.notify(NOTIFICATION_ID, notification)
    }

    private fun buildNotification(
        context: Context,
        title: String,
        text: String,
        stopLabel: String,
        contentIntent: PendingIntent,
        stopIntent: PendingIntent
    ): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setShowWhen(false)
            .setContentIntent(contentIntent)
            .addAction(
                Notification.Action.Builder(
                    android.R.drawable.ic_menu_close_clear_cancel, stopLabel, stopIntent
                ).build()
            )
            .build()
    }

    fun cancelNotification(context: Context) {
        val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
    }
}
