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
  });
}
