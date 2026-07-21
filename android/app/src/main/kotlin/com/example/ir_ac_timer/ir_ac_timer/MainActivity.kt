package com.example.ir_ac_timer.ir_ac_timer

import android.content.Context
import android.content.Intent
import android.hardware.ConsumerIrManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.app.AlarmManager
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.ir_ac_timer/ir"
    private val TAG = "MainActivity"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED) {
                requestPermissions(arrayOf(android.Manifest.permission.POST_NOTIFICATIONS), 1002)
            }
        }
    }

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
                    val frequency           = call.argument<Int>("frequency") ?: AppConstants.DEFAULT_CARRIER_HZ

                    result.success(scheduleTask(
                        mode, targetHour, targetMinute, durationMinutes, patternList,
                        cycleIntervalMin, cycleStartHour, cycleStartMinute, cycleEndHour, cycleEndMinute,
                        frequency
                    ))
                }
                "cancelTask" -> {
                    TaskManager.cancel(this)
                    result.success(true)
                }
                "getTask" -> {
                    result.success(getSavedTask())
                }
                "transmitIr" -> {
                    val patternList = call.argument<List<Int>>("pattern") ?: emptyList()
                    val frequency = call.argument<Int>("frequency") ?: AppConstants.DEFAULT_CARRIER_HZ
                    result.success(IrTransmitter.transmit(this, patternList.toIntArray(), frequency))
                }
                "saveProfiles" -> {
                    val profilesJson = call.argument<String>("profiles") ?: ""
                    AppConstants.prefs(this)
                        .edit().putString(AppConstants.KEY_DEVICE_PROFILES, profilesJson).apply()
                    result.success(true)
                }
                "getProfiles" -> {
                    result.success(AppConstants.prefs(this).getString(AppConstants.KEY_DEVICE_PROFILES, null))
                }
                "saveSelectedProfile" -> {
                    val name = call.argument<String>("name") ?: ""
                    AppConstants.prefs(this)
                        .edit().putString(AppConstants.KEY_SELECTED_PROFILE, name).apply()
                    result.success(true)
                }
                "getSelectedProfile" -> {
                    result.success(AppConstants.prefs(this).getString(AppConstants.KEY_SELECTED_PROFILE, null))
                }
                "getLanguage" -> {
                    result.success(AppConstants.prefs(this)
                        .getString(AppConstants.KEY_LANGUAGE, AppConstants.DEFAULT_LANGUAGE))
                }
                "setLanguage" -> {
                    val lang = call.argument<String>("lang") ?: AppConstants.DEFAULT_LANGUAGE
                    AppConstants.prefs(this)
                        .edit().putString(AppConstants.KEY_LANGUAGE, lang).apply()
                    result.success(true)
                }
                "getStats" -> {
                    result.success(StatsStore.getRaw(this))
                }
                "resetStats" -> {
                    StatsStore.reset(this)
                    result.success(true)
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

        map["postNotificationsGranted"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
            checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) == android.content.pm.PackageManager.PERMISSION_GRANTED else true

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
        cycleEndMinute: Int = -1,
        frequency: Int = AppConstants.DEFAULT_CARRIER_HZ
    ): Boolean {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && !alarmManager.canScheduleExactAlarms()) {
            Log.e(TAG, "Exact alarm permission not granted")
            return false
        }

        val now = System.currentTimeMillis()
        val firstTriggerTime: Long
        var targetEpoch: Long? = null
        var cycleEndEpoch = 0L

        when (mode) {
            AppConstants.MODE_COUNTDOWN -> {
                firstTriggerTime = now + durationMinutes * 60 * 1000L
                targetEpoch = firstTriggerTime
            }
            AppConstants.MODE_RECURRING -> {
                firstTriggerTime = ScheduleCalculator.nextDailyTrigger(now, targetHour, targetMinute)
            }
            AppConstants.MODE_CYCLE -> {
                firstTriggerTime = ScheduleCalculator.cycleFirstTrigger(
                    now, cycleStartHour, cycleStartMinute, cycleIntervalMin
                )
                cycleEndEpoch = ScheduleCalculator.cycleEndEpoch(now, cycleEndHour, cycleEndMinute)
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
            put("frequency", frequency)
            put("oneTimeEpochMillis", targetEpoch ?: JSONObject.NULL)
            put("scheduledTime", now)
            put("cycleIntervalMinutes", cycleIntervalMin)
            put("cycleEndEpochMillis", cycleEndEpoch)
            put("nextTriggerEpochMillis", if (mode == AppConstants.MODE_CYCLE) firstTriggerTime else JSONObject.NULL)
        }

        AppConstants.prefs(this)
            .edit().putString(AppConstants.KEY_ACTIVE_TASK, taskJson.toString()).apply()

        // Set alarm via centralized scheduler
        AlarmScheduler.scheduleExactAlarm(this, firstTriggerTime)

        // Show persistent notification for indefinite cycles
        if (mode == AppConstants.MODE_CYCLE && cycleEndEpoch == 0L) {
            NotificationHelper.showCycleNotification(this, cycleIntervalMin, firstTriggerTime)
        }

        AcTimerWidgetProvider.refresh(this)

        Log.d(TAG, "Task scheduled: mode=$mode firstTrigger=${java.util.Date(firstTriggerTime)} endEpoch=$cycleEndEpoch")
        return true
    }

    private fun getSavedTask(): String? =
        AppConstants.prefs(this).getString(AppConstants.KEY_ACTIVE_TASK, null)
}
