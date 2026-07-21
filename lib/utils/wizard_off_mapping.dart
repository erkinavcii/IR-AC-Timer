// Pure decision logic for saving a "Find My AC" wizard result.
//
// Smart Off-Mapping: when the user confirms a mode/temp signal, the
// family's verified Power OFF code (if any) is saved instead, so the
// nightly timer reliably turns the AC off.

enum WizardSaveKind {
  /// The confirmed signal is itself an OFF code — save as-is.
  direct,

  /// A mode signal was confirmed and the family has a verified OFF code —
  /// save that OFF code under a renamed profile.
  mappedToOff,

  /// A mode signal was confirmed but no verified OFF code exists for the
  /// family — warn instead of saving.
  missingOff,
}

class WizardSaveResolution {
  final WizardSaveKind kind;
  final String profileName;
  final String patternStr;

  const WizardSaveResolution({
    required this.kind,
    required this.profileName,
    required this.patternStr,
  });
}

WizardSaveResolution resolveWizardSave(Map<String, String> set) {
  final rawName = set['name'] ?? 'Wizard Profile';
  final patternStr = set['pattern'] ?? '';
  final family = set['family'] ?? 'Unknown';
  final signalType = set['signalType'] ?? 'mode';
  final offPatternStr = set['offPattern'] ?? '';

  if (signalType == 'off') {
    return WizardSaveResolution(
      kind: WizardSaveKind.direct,
      profileName: rawName,
      patternStr: patternStr,
    );
  }
  if (offPatternStr.isNotEmpty) {
    return WizardSaveResolution(
      kind: WizardSaveKind.mappedToOff,
      profileName: '$family (Zamanlayıcı Kapatma Profili)',
      patternStr: offPatternStr,
    );
  }
  return WizardSaveResolution(
    kind: WizardSaveKind.missingOff,
    profileName: rawName,
    patternStr: patternStr,
  );
}
