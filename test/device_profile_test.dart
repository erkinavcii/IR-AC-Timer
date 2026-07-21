import 'package:flutter_test/flutter_test.dart';
import 'package:ir_ac_timer/models/device_profile.dart';

void main() {
  group('DeviceProfile JSON', () {
    test('round-trips name and pattern', () {
      final original = DeviceProfile(name: 'Bedroom', pattern: [9000, 4500, 560]);
      final restored = DeviceProfile.fromJson(original.toJson());
      expect(restored.name, 'Bedroom');
      expect(restored.pattern, [9000, 4500, 560]);
    });

    test('exposes the built-in default presets', () {
      expect(DeviceProfile.defaultPresets, isNotEmpty);
      expect(DeviceProfile.defaultPresets.first.pattern, isNotEmpty);
    });

    test('parses legacy JSON without a frequency key (defaults to 38 kHz)', () {
      final restored = DeviceProfile.fromJson({
        'name': 'Legacy',
        'pattern': [1, 2, 3],
      });
      expect(restored.frequency, kDefaultCarrierHz);
    });

    test('round-trips an explicit frequency', () {
      final original =
          DeviceProfile(name: 'Panasonic', pattern: [1, 2], frequency: 36000);
      expect(DeviceProfile.fromJson(original.toJson()).frequency, 36000);
    });

    test('default presets carry the default carrier frequency', () {
      for (final p in DeviceProfile.defaultPresets) {
        expect(p.frequency, kDefaultCarrierHz);
      }
    });
  });
}
