import 'package:flutter_test/flutter_test.dart';
import 'package:ir_ac_timer/utils/usage_stats.dart';

void main() {
  const dayMs = 24 * 60 * 60 * 1000;

  group('summarizeStats', () {
    test('empty list yields zeroes and no last transmission', () {
      final s = summarizeStats([], nowMs: 0);
      expect(s.totalTransmissions, 0);
      expect(s.last7Days, 0);
      expect(s.lastTransmissionMs, isNull);
      expect(s.estimatedSavedHours, 0);
    });

    test('counts totals and the last-7-days window', () {
      final now = 30 * dayMs;
      final events = [
        {'t': now - 1 * dayMs, 'mode': 'countdown'}, // within 7d
        {'t': now - 6 * dayMs, 'mode': 'recurring'}, // within 7d
        {'t': now - 10 * dayMs, 'mode': 'cycle'}, // outside 7d
      ];
      final s = summarizeStats(events, nowMs: now);
      expect(s.totalTransmissions, 3);
      expect(s.last7Days, 2);
      expect(s.lastTransmissionMs, now - 1 * dayMs);
    });

    test('estimated saved runtime counts scheduled modes only', () {
      final now = 10 * dayMs;
      final events = [
        {'t': now, 'mode': 'countdown'},
        {'t': now, 'mode': 'recurring'},
        {'t': now, 'mode': 'manual_widget'}, // excluded from estimate
      ];
      final s = summarizeStats(events, nowMs: now);
      expect(s.totalTransmissions, 3);
      expect(s.estimatedSavedHours, 2 * kEstimatedSavedHoursPerEvent);
    });

    test('ignores malformed entries', () {
      final s = summarizeStats([
        {'mode': 'countdown'}, // no 't'
        'garbage',
        {'t': 'not-an-int', 'mode': 'cycle'},
      ], nowMs: 0);
      expect(s.totalTransmissions, 0);
    });
  });
}
