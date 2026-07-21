import 'package:flutter/material.dart';

import '../controllers/profile_controller.dart';
import '../l10n/app_strings.dart';
import '../models/device_profile.dart';
import '../theme/app_colors.dart';
import '../utils/ir_pattern.dart';

/// Expandable "AC Profiles" card: profile dropdown + CRUD dialogs +
/// raw pattern editor + test/save buttons.
class ProfilesSection extends StatefulWidget {
  final ProfileController controller;
  final VoidCallback onTestTransmit;
  final void Function(String message, Color color) onSnack;

  const ProfilesSection({
    super.key,
    required this.controller,
    required this.onTestTransmit,
    required this.onSnack,
  });

  @override
  State<ProfilesSection> createState() => _ProfilesSectionState();
}

class _ProfilesSectionState extends State<ProfilesSection> {
  bool _showProfiles = false;

  ProfileController get _profiles => widget.controller;

  Future<void> _saveChanges() async {
    final errorKey = await _profiles.saveChangesToCurrent();
    if (errorKey != null) {
      widget.onSnack(AppStrings.get(errorKey), AppColors.danger);
    } else {
      widget.onSnack(AppStrings.get('savedOk'), AppColors.success);
    }
  }

  Future<void> _delete(DeviceProfile profile) async {
    final errorKey = await _profiles.delete(profile);
    if (errorKey != null) widget.onSnack(AppStrings.get(errorKey), AppColors.warning);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _profiles,
      builder: (context, _) {
        final selected = _profiles.selectedProfile;
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            GestureDetector(
              onTap: () => setState(() => _showProfiles = !_showProfiles),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.devices_other_rounded, color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(AppStrings.get('irManagement'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                    if (selected != null) Text(selected.name, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
                  ])),
                  AnimatedRotation(turns: _showProfiles ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, color: AppColors.textDim)),
                ]),
              ),
            ),
            if (_showProfiles) ...[
              const Divider(color: AppColors.cardBorder, height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(AppStrings.get('activeProfile'), style: const TextStyle(fontSize: 11, color: AppColors.textDim, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DeviceProfile>(
                            value: selected,
                            isExpanded: true,
                            dropdownColor: AppColors.card,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            onChanged: _profiles.select,
                            items: _profiles.profiles.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _iconBtn(Icons.edit_outlined, _showEditProfileDialog),
                    _iconBtn(Icons.add_rounded, _showAddProfileDialog),
                    _iconBtn(Icons.delete_outline, () { if (selected != null) _delete(selected); }, color: AppColors.danger),
                  ]),
                  const SizedBox(height: 14),
                  Text(AppStrings.get('irPatternLabel'), style: const TextStyle(fontSize: 11, color: AppColors.textDim, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _profiles.patternController,
                    maxLines: 3,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '9000, 4500, 560, 560...',
                      hintStyle: const TextStyle(color: AppColors.textDim),
                      filled: true, fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onTestTransmit,
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text(AppStrings.get('testSignal'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(0, 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _saveChanges,
                      icon: const Icon(Icons.save_outlined, size: 16, color: Colors.black),
                      label: Text(AppStrings.get('saveChanges'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ]),
                ]),
              ),
            ],
          ]),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = AppColors.textSecondary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────
  void _showAddProfileDialog() {
    final nc = TextEditingController();
    final cc = TextEditingController(text: '9000, 4500, 560, 560');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.get('addProfile'), style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(nc, AppStrings.get('profileName'), AppStrings.get('profileNameHint')),
          const SizedBox(height: 12),
          _dialogField(cc, AppStrings.get('signalPattern'), '9000, 4500, 560...', maxLines: 3),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final p = tryParseIrPattern(cc.text);
              if (p == null) {
                widget.onSnack(AppStrings.get('invalidPattern'), AppColors.danger);
                return;
              }
              if (nc.text.trim().isEmpty) return;
              Navigator.pop(context);
              final errorKey = await _profiles.add(nc.text.trim(), p);
              if (errorKey != null) widget.onSnack(AppStrings.get(errorKey), AppColors.warning);
            },
            child: Text(AppStrings.get('add')),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    final selected = _profiles.selectedProfile;
    if (selected == null) return;
    final nc = TextEditingController(text: selected.name);
    final cc = TextEditingController(text: formatIrPattern(selected.pattern));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppStrings.get('editProfile'), style: const TextStyle(color: AppColors.textPrimary)),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _dialogField(nc, AppStrings.get('profileName'), ''),
          const SizedBox(height: 12),
          _dialogField(cc, AppStrings.get('signalPattern'), '', maxLines: 3),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(AppStrings.get('cancel'), style: const TextStyle(color: AppColors.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              final p = tryParseIrPattern(cc.text);
              if (p == null) {
                widget.onSnack(AppStrings.get('invalidPattern'), AppColors.danger);
                return;
              }
              if (nc.text.trim().isEmpty) return;
              _profiles.edit(selected, nc.text.trim(), p);
              Navigator.pop(context);
            },
            child: Text(AppStrings.get('save')),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String label, String hint, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontFamily: maxLines > 1 ? 'monospace' : 'Roboto'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textDim),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.accent)),
      ),
    );
  }
}
