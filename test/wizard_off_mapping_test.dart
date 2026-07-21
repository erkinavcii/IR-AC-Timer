import 'package:flutter_test/flutter_test.dart';
import 'package:ir_ac_timer/utils/wizard_off_mapping.dart';

void main() {
  group('resolveWizardSave', () {
    test('an off signal is saved directly under its own name', () {
      final r = resolveWizardSave({
        'name': 'LG OFF',
        'pattern': '9000, 4500',
        'family': 'LG',
        'signalType': 'off',
        'offPattern': '',
      });
      expect(r.kind, WizardSaveKind.direct);
      expect(r.profileName, 'LG OFF');
      expect(r.patternStr, '9000, 4500');
    });

    test('a mode signal with an OFF pattern maps to the OFF code, renamed', () {
      final r = resolveWizardSave({
        'name': 'LG Cool 24',
        'pattern': '1, 2, 3',
        'family': 'LG',
        'signalType': 'mode',
        'offPattern': '9000, 4500, 560',
      });
      expect(r.kind, WizardSaveKind.mappedToOff);
      expect(r.profileName, contains('LG'));
      expect(r.patternStr, '9000, 4500, 560');
    });

    test('a mode signal without an OFF pattern is reported as missing', () {
      final r = resolveWizardSave({
        'name': 'Samsung Cool',
        'pattern': '1, 2, 3',
        'family': 'Samsung',
        'signalType': 'mode',
        'offPattern': '',
      });
      expect(r.kind, WizardSaveKind.missingOff);
    });

    test('missing signalType defaults to mode (missing-off when no offPattern)',
        () {
      final r = resolveWizardSave({
        'name': 'Unknown',
        'pattern': '1, 2',
      });
      expect(r.kind, WizardSaveKind.missingOff);
    });
  });
}
