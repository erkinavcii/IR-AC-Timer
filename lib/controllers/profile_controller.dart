import 'package:flutter/widgets.dart';

import '../models/device_profile.dart';
import '../services/ir_platform_service.dart';
import '../utils/ir_pattern.dart';

/// Owns the device-profile list, the current selection, and the raw
/// pattern text field. Mutating methods return an AppStrings key on
/// failure (for the UI to show as a warning) or null on success.
class ProfileController extends ChangeNotifier {
  final IrPlatformService _service;

  List<DeviceProfile> profiles = [];
  DeviceProfile? selectedProfile;
  final TextEditingController patternController = TextEditingController();

  ProfileController(this._service);

  @override
  void dispose() {
    patternController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    try {
      var loaded = await _service.getProfiles();
      if (loaded.isEmpty) {
        loaded = List.from(DeviceProfile.defaultPresets);
        await _service.saveProfiles(loaded);
      }
      final selectedName = await _service.getSelectedProfileName();
      final selected = loaded.firstWhere(
        (p) => p.name == selectedName,
        orElse: () => loaded.first,
      );
      profiles = loaded;
      _applySelection(selected);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profiles: $e');
    }
  }

  void _applySelection(DeviceProfile p) {
    selectedProfile = p;
    patternController.text = formatIrPattern(p.pattern);
  }

  /// Pattern currently in the text field, or null (invalid input).
  List<int>? parseCurrentPattern() =>
      tryParseIrPattern(patternController.text);

  /// Carrier frequency of the selected profile (default if none selected).
  int get currentFrequency => selectedProfile?.frequency ?? kDefaultCarrierHz;

  Future<void> select(DeviceProfile? p) async {
    if (p == null) return;
    _applySelection(p);
    notifyListeners();
    await _service.saveSelectedProfileName(p.name);
  }

  Future<String?> add(String name, List<int> pattern,
      {int frequency = kDefaultCarrierHz}) async {
    if (name.isEmpty) return null;
    if (profiles.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      return 'profileExists';
    }
    final np = DeviceProfile(name: name, pattern: pattern, frequency: frequency);
    profiles = List.from(profiles)..add(np);
    await _service.saveProfiles(profiles);
    await select(np);
    return null;
  }

  Future<void> edit(DeviceProfile old, String newName, List<int> newPattern,
      {int frequency = kDefaultCarrierHz}) async {
    if (newName.isEmpty) return;
    profiles = profiles
        .map((p) => p.name == old.name
            ? DeviceProfile(name: newName, pattern: newPattern, frequency: frequency)
            : p)
        .toList();
    await _service.saveProfiles(profiles);
    await select(profiles.firstWhere((p) => p.name == newName));
  }

  Future<String?> delete(DeviceProfile profile) async {
    if (profiles.length <= 1) return 'minOneProfile';
    profiles = List.from(profiles)..removeWhere((p) => p.name == profile.name);
    await _service.saveProfiles(profiles);
    await select(profiles.first);
    return null;
  }

  /// Saves the pattern text field into the selected profile.
  /// Returns 'invalidPattern' on bad input, null on success.
  Future<String?> saveChangesToCurrent() async {
    final current = selectedProfile;
    if (current == null) return null;
    final pattern = parseCurrentPattern();
    if (pattern == null) return 'invalidPattern';
    await edit(current, current.name, pattern, frequency: current.frequency);
    return null;
  }

  /// Adds or replaces a profile by name (wizard save), then selects it.
  Future<void> upsert(String name, List<int> pattern) async {
    final target = DeviceProfile(name: name, pattern: pattern);
    final index =
        profiles.indexWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    final updated = List<DeviceProfile>.from(profiles);
    if (index != -1) {
      updated[index] = target;
    } else {
      updated.add(target);
    }
    profiles = updated;
    await _service.saveProfiles(profiles);
    await select(target);
  }
}
