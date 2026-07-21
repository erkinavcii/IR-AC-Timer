import 'package:flutter_test/flutter_test.dart';
import 'package:ir_ac_timer/utils/countdown_format.dart';

void main() {
  group('formatHms', () {
    test('pads hours, minutes and seconds to two digits', () {
      expect(formatHms(const Duration(hours: 1, minutes: 2, seconds: 3)),
          '01:02:03');
      expect(formatHms(Duration.zero), '00:00:00');
    });

    test('rolls minutes/seconds within the hour and keeps total hours', () {
      expect(formatHms(const Duration(hours: 25, minutes: 61)), '26:01:00');
    });
  });

  group('formatHmFromEpoch', () {
    test('formats a local time as HH:mm', () {
      final dt = DateTime(2026, 1, 1, 9, 5);
      expect(formatHmFromEpoch(dt.millisecondsSinceEpoch), '09:05');
    });
  });

  group('countdownProgress', () {
    test('is 1.0 at scheduling and 0.0 at the target', () {
      expect(
          countdownProgress(
              targetEpochMs: 1000, scheduledEpochMs: 0, nowEpochMs: 0),
          1.0);
      expect(
          countdownProgress(
              targetEpochMs: 1000, scheduledEpochMs: 0, nowEpochMs: 1000),
          0.0);
      expect(
          countdownProgress(
              targetEpochMs: 1000, scheduledEpochMs: 0, nowEpochMs: 500),
          0.5);
    });

    test('clamps to [0,1] and guards against a zero span', () {
      expect(
          countdownProgress(
              targetEpochMs: 1000, scheduledEpochMs: 0, nowEpochMs: 2000),
          0.0);
      expect(
          countdownProgress(
              targetEpochMs: 100, scheduledEpochMs: 100, nowEpochMs: 100),
          0.0);
    });
  });

  group('cycleProgress', () {
    test('is 0.0 right after a fire and approaches 1.0 near the next', () {
      const intervalMs = 10 * 60 * 1000;
      final next = intervalMs; // fired at t=0, next at +interval
      expect(
          cycleProgress(
              nextTriggerEpochMs: next, intervalMinutes: 10, nowEpochMs: 0),
          0.0);
      expect(
          cycleProgress(
              nextTriggerEpochMs: next,
              intervalMinutes: 10,
              nowEpochMs: next),
          1.0);
    });
  });
}
