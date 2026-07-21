import 'package:flutter_test/flutter_test.dart';
import 'package:ir_ac_timer/utils/ir_pattern.dart';

void main() {
  group('tryParseIrPattern', () {
    test('parses a valid comma-separated pattern, trimming whitespace', () {
      expect(tryParseIrPattern('9000, 4500, 560,560'),
          [9000, 4500, 560, 560]);
      expect(tryParseIrPattern('  100 ,  200  '), [100, 200]);
    });

    test('rejects empty or whitespace-only input', () {
      expect(tryParseIrPattern(''), isNull);
      expect(tryParseIrPattern('   '), isNull);
    });

    test('rejects non-numeric tokens', () {
      expect(tryParseIrPattern('9000, abc, 560'), isNull);
      expect(tryParseIrPattern('9000,,560'), isNull);
    });

    test('rejects negative and zero durations', () {
      expect(tryParseIrPattern('9000, -560, 560'), isNull);
      expect(tryParseIrPattern('9000, 0, 560'), isNull);
    });

    test('rejects a single value (needs at least a mark/space pair)', () {
      expect(tryParseIrPattern('9000'), isNull);
    });

    test('rejects durations above the sanity cap', () {
      expect(tryParseIrPattern('9000, ${kMaxIrMarkMicros + 1}'), isNull);
      expect(tryParseIrPattern('9000, $kMaxIrMarkMicros'),
          [9000, kMaxIrMarkMicros]);
    });

    test('rejects patterns longer than the max length', () {
      final tooLong = List.filled(kMaxIrPatternLength + 1, '100').join(',');
      expect(tryParseIrPattern(tooLong), isNull);
    });

    test('accepts a pattern exactly at the max length', () {
      final maxLen = List.filled(kMaxIrPatternLength, '100').join(',');
      expect(tryParseIrPattern(maxLen)?.length, kMaxIrPatternLength);
    });
  });

  group('formatIrPattern', () {
    test('joins with ", " and round-trips through the parser', () {
      const pattern = [9000, 4500, 560];
      final formatted = formatIrPattern(pattern);
      expect(formatted, '9000, 4500, 560');
      expect(tryParseIrPattern(formatted), pattern);
    });
  });
}
