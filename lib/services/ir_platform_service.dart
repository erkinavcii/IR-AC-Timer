import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/device_profile.dart';

/// Permission state reported by the native side.
class AppPermissions {
  final bool exactAlarmGranted;
  final bool batteryOptimizationIgnored;
  final bool postNotificationsGranted;

  const AppPermissions({
    required this.exactAlarmGranted,
    required this.batteryOptimizationIgnored,
    required this.postNotificationsGranted,
  });
}

/// The single Dart-side wrapper around the native MethodChannel.
/// All platform calls go through here so the channel name and argument
/// shapes live in exactly one place.
class IrPlatformService {
  static const MethodChannel _channel =
      MethodChannel('com.example.ir_ac_timer/ir');

  Future<bool> hasIrEmitter() async =>
      await _channel.invokeMethod('hasIrEmitter') as bool? ?? false;

  Future<AppPermissions> checkPermissions() async {
    final Map<dynamic, dynamic>? perms =
        await _channel.invokeMethod('checkPermissions');
    return AppPermissions(
      exactAlarmGranted: perms?['exactAlarmGranted'] ?? false,
      batteryOptimizationIgnored: perms?['batteryOptimizationIgnored'] ?? false,
      postNotificationsGranted: perms?['postNotificationsGranted'] ?? false,
    );
  }

  Future<void> requestExactAlarmPermission() =>
      _channel.invokeMethod('requestExactAlarmPermission');

  Future<void> requestIgnoreBatteryOptimizations() =>
      _channel.invokeMethod('requestIgnoreBatteryOptimizations');

  Future<bool> openAutostartSettings() async =>
      await _channel.invokeMethod('openAutostartSettings') as bool? ?? false;

  Future<bool> scheduleTask(Map<String, dynamic> args) async =>
      await _channel.invokeMethod('scheduleTask', args) as bool? ?? false;

  Future<void> cancelTask() => _channel.invokeMethod('cancelTask');

  Future<Map<String, dynamic>?> getTask() async {
    final String? taskStr = await _channel.invokeMethod('getTask');
    if (taskStr == null) return null;
    return jsonDecode(taskStr) as Map<String, dynamic>;
  }

  Future<bool> transmitIr(List<int> pattern) async =>
      await _channel.invokeMethod('transmitIr', {'pattern': pattern})
          as bool? ??
      false;

  Future<List<DeviceProfile>> getProfiles() async {
    final String? profilesJsonStr = await _channel.invokeMethod('getProfiles');
    if (profilesJsonStr == null || profilesJsonStr.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(profilesJsonStr);
    return decoded.map((e) => DeviceProfile.fromJson(e)).toList();
  }

  Future<void> saveProfiles(List<DeviceProfile> profiles) =>
      _channel.invokeMethod('saveProfiles', {
        'profiles': jsonEncode(profiles.map((e) => e.toJson()).toList()),
      });

  Future<String?> getSelectedProfileName() =>
      _channel.invokeMethod('getSelectedProfile');

  Future<void> saveSelectedProfileName(String name) =>
      _channel.invokeMethod('saveSelectedProfile', {'name': name});

  Future<String> getLanguage() async =>
      await _channel.invokeMethod('getLanguage') as String? ?? 'tr';

  Future<void> setLanguage(String lang) =>
      _channel.invokeMethod('setLanguage', {'lang': lang});
}
