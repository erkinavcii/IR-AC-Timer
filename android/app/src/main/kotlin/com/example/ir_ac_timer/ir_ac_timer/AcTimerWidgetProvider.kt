package com.example.ir_ac_timer.ir_ac_timer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.util.Log
import android.widget.RemoteViews
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Home-screen widget: a one-tap "AC OFF" button plus a static "Next: HH:mm"
 * label. The label is refreshed at schedule/cancel/reschedule points and on
 * the system update tick — it is not a live countdown (that would need
 * per-minute alarms or a foreground service).
 */
class AcTimerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, buildViews(context))
        }
    }

    companion object {
        private const val TAG = "AcTimerWidget"

        /** Rebuilds every widget instance — call after schedule/cancel/fire. */
        fun refresh(context: Context) {
            try {
                val mgr = AppWidgetManager.getInstance(context)
                val ids = mgr.getAppWidgetIds(
                    ComponentName(context, AcTimerWidgetProvider::class.java)
                )
                if (ids.isEmpty()) return
                val views = buildViews(context)
                for (id in ids) mgr.updateAppWidget(id, views)
            } catch (e: Exception) {
                Log.e(TAG, "Widget refresh failed: ${e.message}")
            }
        }

        private fun localizedContext(context: Context): Context {
            val lang = AppConstants.prefs(context)
                .getString(AppConstants.KEY_LANGUAGE, AppConstants.DEFAULT_LANGUAGE)
                ?: AppConstants.DEFAULT_LANGUAGE
            val config = Configuration(context.resources.configuration).apply {
                setLocale(Locale(lang))
            }
            return context.createConfigurationContext(config)
        }

        private fun buildViews(context: Context): RemoteViews {
            val loc = localizedContext(context)
            val views = RemoteViews(context.packageName, R.layout.widget_ac_timer)
            views.setTextViewText(R.id.widget_title, loc.getString(R.string.widget_title))
            views.setTextViewText(R.id.widget_off_button, loc.getString(R.string.widget_off_button))
            views.setTextViewText(R.id.widget_next, nextTriggerText(context, loc))

            val intent = Intent(context, TransmitNowReceiver::class.java)
            val pi = PendingIntent.getBroadcast(
                context, AppConstants.REQUEST_CODE_WIDGET_TRANSMIT, intent,
                AlarmScheduler.pendingIntentFlags()
            )
            views.setOnClickPendingIntent(R.id.widget_off_button, pi)
            return views
        }

        /** "Next: HH:mm" from the active task, or an em dash when idle. */
        private fun nextTriggerText(context: Context, loc: Context): String {
            val none = loc.getString(R.string.widget_next, loc.getString(R.string.widget_next_none))
            val raw = AppConstants.prefs(context)
                .getString(AppConstants.KEY_ACTIVE_TASK, null) ?: return none
            return try {
                val task = JSONObject(raw)
                val epoch: Long? = when (task.optString("mode", "")) {
                    AppConstants.MODE_COUNTDOWN -> task.optLong("oneTimeEpochMillis", 0L).takeIf { it > 0 }
                    AppConstants.MODE_CYCLE -> task.optLong("nextTriggerEpochMillis", 0L).takeIf { it > 0 }
                    AppConstants.MODE_RECURRING -> ScheduleCalculator.nextDailyTrigger(
                        System.currentTimeMillis(),
                        task.optInt("targetHour", 0),
                        task.optInt("targetMinute", 0)
                    )
                    else -> null
                }
                if (epoch == null) none
                else loc.getString(
                    R.string.widget_next,
                    SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date(epoch))
                )
            } catch (e: Exception) {
                none
            }
        }
    }
}
