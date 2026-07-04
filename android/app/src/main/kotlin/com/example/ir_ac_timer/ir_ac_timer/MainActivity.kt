package com.example.ir_ac_timer.ir_ac_timer

import android.content.Context
import android.content.Intent
import android.hardware.ConsumerIrManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.app.AlarmManager
import android.app.PendingIntent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ir_ac_timer/ir"
    private val REQUEST_CODE = 1001
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create notification channel once at startup
        NotificationHelper.createChannel(this)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasIrEmitter" -> {
                    val irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
                    result.success(irManager != null && irManager.hasIrEmitter())
                }
                "checkPermissions" -> {
                    result.success(checkAppPermissions())
                }
                "requestExactAlarmPermission" -> {
                    requestExactAlarmPermission()
                    result.success(true)
                }
                "requestIgnoreBatteryOptimizations" -> {
                    requestIgnoreBatteryOptimizations()
                    result.success(true)
                }
                "openAutostartSettings" -> {
                    result.success(openAutostartSettings())
                }
                "scheduleTask" -> {
                    val mode                = call.argument<String>("mode") ?: ""
                    val targetHour          = call.argument<Int>("targetHour") ?: 0
                    val targetMinute        = call.argument<Int>("targetMinute") ?: 0
                    val durationMinutes     = call.argument<Int>("durationMinutes") ?: 0
                    val patternList         = call.argument<List<Int>>("pattern") ?: emptyList()
                    val cycleIntervalMin    = call.argument<Int>("cycleIntervalMinutes") ?: 30
                    val cycleStartHour      = call.argument<Int>("cycleStartHour") ?: -1
                    val cycleStartMinute    = call.argument<Int>("cycleStartMinute") ?: -1
                    val cycleEndHour        = call.argument<Int>("cycleEndHour") ?: -1
                    val cycleEndMinute      = call.argument<Int>("cycleEndMinute") ?: -1

                    result.success(scheduleTask(
                        mode, targetHour, targetMinute, durationMinutes, patternList,
                        cycleIntervalMin, cycleStartHour, cycleStartMinute, cycleEndHour, cycleEndMinute
                    ))
                }
                "cancelTask" -> {
                    cancelTask()
                    result.success(true)
                }
                "getTask" -> {
                    result.success(getSavedTask())
                }
                "transmitIr" -> {
                    val patternList = call.argument<List<Int>>("pattern") ?: emptyList()
                    result.success(transmitIrSignal(patternList.toIntArray()))
                }
                "saveProfiles" -> {
                    val profilesJson = call.argument<String>("profiles") ?: ""
                    getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
                        .edit().putString("device_profiles", profilesJson).apply()
                    result.success(true)
                }
                "getProfiles" -> {
                    val prefs = getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
                    result.success(prefs.getString("device_profiles", null))
                }
                "saveSelectedProfile" -> {
                    val name = call.argument<String>("name") ?: ""
                    getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
                        .edit().putString("selected_profile_name", name).apply()
                    result.success(true)
                }
                "getSelectedProfile" -> {
                    val prefs = getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
                    result.success(prefs.getString("selected_profile_name", null))
                }
                else -> result.notImplemented()
            }
        }
    }

    // ── Permission helpers ────────────────────────────────────
    private fun checkAppPermissions(): Map<String, Boolean> {
        val map = HashMap<String, Boolean>()

        val pm = getSystemService(Context.POWER_SERVICE) as? PowerManager
        map["batteryOptimizationIgnored"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && pm != null)
            pm.isIgnoringBatteryOptimizations(packageName) else true

        val am = getSystemService(Context.ALARM_SERVICE) as? AlarmManager
        map["exactAlarmGranted"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && am != null)
            am.canScheduleExactAlarms() else true

        return map
    }

    private fun requestExactAlarmPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            } catch (e: Exception) {
                startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            }
        }
    }

    private fun requestIgnoreBatteryOptimizations() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                startActivity(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:$packageName")
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                })
            } catch (e: Exception) {
                Log.e(TAG, "Failed to open battery optimization: ${e.message}")
            }
        }
    }

    private fun openAutostartSettings(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()
        val intents = ArrayList<Intent>()

        if (manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco")) {
            intents.add(Intent().setClassName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"))
        }
        intents.add(Intent().setClassName("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"))
        intents.add(Intent().setClassName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"))
        intents.add(Intent().setClassName("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"))
        intents.add(Intent().setClassName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"))
        intents.add(Intent().setClassName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"))
        intents.add(Intent(Settings.ACTION_SETTINGS))

        for (intent in intents) {
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            try { startActivity(intent); return true } catch (_: Exception) {}
        }
        return false
    }

    // ── IR transmit ───────────────────────────────────────────
    private fun transmitIrSignal(pattern: IntArray): Boolean {
        val irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        return if (irManager != null && irManager.hasIrEmitter()) {
            try { irManager.transmit(38000, pattern); true }
            catch (e: Exception) { Log.e(TAG, "IR transmit error: ${e.message}"); false }
        } else false
    }

    // ── Schedule task ─────────────────────────────────────────
    private fun scheduleTask(
        mode: String,
        targetHour: Int,
        targetMinute: Int,
        durationMinutes: Int,
        patternList: List<Int>,
        cycleIntervalMin: Int = 30,
        cycleStartHour: Int = -1,
        cycleStartMinute: Int = -1,
        cycleEndHour: Int = -1,
        cycleEndMinute: Int = -1
    ): Boolean {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            Log.e(TAG, "Exact alarm permission not granted")
            return false
        }

        var firstTriggerTime: Long
        var targetEpoch: Long? = null
        var cycleEndEpoch = 0L

        when (mode) {
            "countdown" -> {
                firstTriggerTime = System.currentTimeMillis() + durationMinutes * 60 * 1000L
                targetEpoch = firstTriggerTime
            }
            "recurring" -> {
                val cal = Calendar.getInstance().apply {
                    set(Calendar.HOUR_OF_DAY, targetHour)
                    set(Calendar.MINUTE, targetMinute)
                    set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
                }
                if (cal.timeInMillis <= System.currentTimeMillis()) cal.add(Calendar.DAY_OF_YEAR, 1)
                firstTriggerTime = cal.timeInMillis
            }
            "cycle" -> {
                // ── Start time ──────────────────────────────
                firstTriggerTime = if (cycleStartHour >= 0 && cycleStartMinute >= 0) {
                    // User specified a start time → first signal fires AT that time
                    val startCal = Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, cycleStartHour)
                        set(Calendar.MINUTE, cycleStartMinute)
                        set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
                    }
                    // If start time already passed today, push to tomorrow
                    if (startCal.timeInMillis <= System.currentTimeMillis()) {
                        startCal.add(Calendar.DAY_OF_YEAR, 1)
                    }
                    startCal.timeInMillis
                } else {
                    // No start time → first trigger is now + interval
                    System.currentTimeMillis() + cycleIntervalMin * 60 * 1000L
                }

                // ── End time ────────────────────────────────
                if (cycleEndHour >= 0 && cycleEndMinute >= 0) {
                    val endCal = Calendar.getInstance().apply {
                        set(Calendar.HOUR_OF_DAY, cycleEndHour)
                        set(Calendar.MINUTE, cycleEndMinute)
                        set(Calendar.SECOND, 0); set(Calendar.MILLISECOND, 0)
                    }
                    if (endCal.timeInMillis <= System.currentTimeMillis()) {
                        endCal.add(Calendar.DAY_OF_YEAR, 1)
                    }
                    cycleEndEpoch = endCal.timeInMillis
                }
            }
            else -> return false
        }

        // Serialize and persist task
        val patternString = patternList.joinToString(",")
        val taskJson = JSONObject().apply {
            put("mode", mode)
            put("targetHour", targetHour)
            put("targetMinute", targetMinute)
            put("durationMinutes", durationMinutes)
            put("pattern", patternString)
            put("oneTimeEpochMillis", targetEpoch ?: JSONObject.NULL)
            put("scheduledTime", System.currentTimeMillis())
            put("cycleIntervalMinutes", cycleIntervalMin)
            put("cycleEndEpochMillis", cycleEndEpoch)
            put("nextTriggerEpochMillis", if (mode == "cycle") firstTriggerTime else JSONObject.NULL)
        }

        getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
            .edit().putString("active_task", taskJson.toString()).apply()

        // Set alarm
        val alarmIntent = Intent(this, AlarmReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        else PendingIntent.FLAG_UPDATE_CURRENT
        val pendingIntent = PendingIntent.getBroadcast(this, REQUEST_CODE, alarmIntent, flags)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, firstTriggerTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, firstTriggerTime, pendingIntent)
        }

        // Show persistent notification for indefinite cycles
        if (mode == "cycle" && cycleEndEpoch == 0L) {
            NotificationHelper.showCycleNotification(this, cycleIntervalMin, firstTriggerTime)
        }

        Log.d(TAG, "Task scheduled: mode=$mode firstTrigger=${java.util.Date(firstTriggerTime)} endEpoch=$cycleEndEpoch")
        return true
    }

    // ── Cancel task ───────────────────────────────────────────
    private fun cancelTask() {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val alarmIntent = Intent(this, AlarmReceiver::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        else PendingIntent.FLAG_UPDATE_CURRENT
        val pendingIntent = PendingIntent.getBroadcast(this, REQUEST_CODE, alarmIntent, flags)

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()

        getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE)
            .edit().remove("active_task").apply()

        // Always attempt to dismiss any lingering notification
        NotificationHelper.cancelNotification(this)
        Log.d(TAG, "Task cancelled.")
    }

    private fun getSavedTask(): String? =
        getSharedPreferences("ir_ac_timer_prefs", Context.MODE_PRIVATE).getString("active_task", null)
}
