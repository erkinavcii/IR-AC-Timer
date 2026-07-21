import 'dart:async';

import 'package:flutter/foundation.dart';

import '../l10n/app_strings.dart';
import '../models/device_profile.dart';
import '../services/ir_platform_service.dart';
import '../utils/countdown_format.dart' as fmt;

/// User input collected by the setup view for scheduling a task.
class TaskSetupData {
  final String mode;
  final int targetHour;
  final int targetMinute;
  final int durationMinutes;
  final int cycleIntervalMinutes;
  final int cycleStartHour;
  final int cycleStartMinute;
  final int cycleEndHour;
  final int cycleEndMinute;

  const TaskSetupData({
    required this.mode,
    this.targetHour = 0,
    this.targetMinute = 0,
    this.durationMinutes = 0,
    this.cycleIntervalMinutes = 30,
    this.cycleStartHour = -1,
    this.cycleStartMinute = -1,
    this.cycleEndHour = -1,
    this.cycleEndMinute = -1,
  });
}

/// Owns device/permission status, the active task, and the countdown
/// display state. Polls the native side every 5 seconds and ticks the
/// countdown once per second while a task is active.
class TaskController extends ChangeNotifier {
  final IrPlatformService _service;

  bool hasIr = false;
  bool exactAlarmGranted = false;
  bool batteryOptimizationIgnored = false;
  Map<String, dynamic>? activeTask;
  String timeRemainingStr = '';
  double countdownProgress = 0.0;

  Timer? _countdownTimer;
  Timer? _statusPollTimer;
  bool _disposed = false;

  TaskController(this._service);

  void startPolling() {
    refresh();
    _statusPollTimer =
        Timer.periodic(const Duration(seconds: 5), (_) => refresh());
  }

  @override
  void dispose() {
    _disposed = true;
    _countdownTimer?.cancel();
    _statusPollTimer?.cancel();
    super.dispose();
  }

  Future<void> refresh() async {
    try {
      final ir = await _service.hasIrEmitter();
      final perms = await _service.checkPermissions();
      final task = await _service.getTask();
      if (_disposed) return;
      hasIr = ir;
      exactAlarmGranted = perms.exactAlarmGranted;
      batteryOptimizationIgnored = perms.batteryOptimizationIgnored;
      activeTask = task;
      _updateCountdown();
      notifyListeners();
    } catch (e) {
      debugPrint('Status check error: $e');
    }
  }

  Future<bool> schedule(TaskSetupData data, List<int> pattern,
      {int frequency = kDefaultCarrierHz}) async {
    final args = <String, dynamic>{
      'mode': data.mode,
      'targetHour': data.targetHour,
      'targetMinute': data.targetMinute,
      'durationMinutes': data.durationMinutes,
      'pattern': pattern,
      'frequency': frequency,
    };
    if (data.mode == 'cycle') {
      args['cycleIntervalMinutes'] = data.cycleIntervalMinutes;
      args['cycleStartHour'] = data.cycleStartHour;
      args['cycleStartMinute'] = data.cycleStartMinute;
      args['cycleEndHour'] = data.cycleEndHour;
      args['cycleEndMinute'] = data.cycleEndMinute;
    }
    final ok = await _service.scheduleTask(args);
    if (ok) await refresh();
    return ok;
  }

  Future<void> cancelActiveTask() async {
    await _service.cancelTask();
    _countdownTimer?.cancel();
    activeTask = null;
    timeRemainingStr = '';
    countdownProgress = 0.0;
    notifyListeners();
  }

  Future<bool> transmit(List<int> pattern,
          {int frequency = kDefaultCarrierHz}) =>
      _service.transmitIr(pattern, frequency: frequency);

  void _updateCountdown() {
    _countdownTimer?.cancel();
    final task = activeTask;
    if (task == null) return;
    final String mode = task['mode'] ?? '';

    if (mode == 'countdown') {
      final int target = task['oneTimeEpochMillis'] ?? 0;
      final int scheduled = task['scheduledTime'] ?? 0;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final remaining = target - now;
        if (remaining <= 0) {
          timer.cancel();
          refresh();
          return;
        }
        timeRemainingStr = fmt.formatHms(Duration(milliseconds: remaining));
        countdownProgress = fmt.countdownProgress(
            targetEpochMs: target, scheduledEpochMs: scheduled, nowEpochMs: now);
        if (!_disposed) notifyListeners();
      });
    } else if (mode == 'recurring') {
      final h = task['targetHour'] ?? 0;
      final m = task['targetMinute'] ?? 0;
      timeRemainingStr =
          "${AppStrings.get('everyDay')} ${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
      countdownProgress = 1.0;
    } else if (mode == 'cycle') {
      final int intervalMin = task['cycleIntervalMinutes'] ?? 30;
      final int initialNext = task['nextTriggerEpochMillis'] ?? 0;
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        // Re-read from the task map in case the 5s poll refreshed it
        final int curNext = activeTask?['nextTriggerEpochMillis'] ?? initialNext;
        final now = DateTime.now().millisecondsSinceEpoch;
        final remaining = curNext - now;
        if (remaining <= 0) {
          timer.cancel();
          refresh();
          return;
        }
        timeRemainingStr = fmt.formatHms(Duration(milliseconds: remaining));
        countdownProgress = fmt.cycleProgress(
            nextTriggerEpochMs: curNext,
            intervalMinutes: intervalMin,
            nowEpochMs: now);
        if (!_disposed) notifyListeners();
      });
    }
  }
}
