import 'package:flutter/material.dart';

import '../controllers/task_controller.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import 'gradient_button.dart';

/// Mode tabs + countdown/alarm/cycle pickers. Owns all schedule input
/// state and reports the final choice through [onStart].
class SetupView extends StatefulWidget {
  final void Function(TaskSetupData data) onStart;

  const SetupView({super.key, required this.onStart});

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> {
  String _selectedMode = 'countdown';
  int _selectedHour = 1;
  int _selectedMinute = 0;
  int _alarmHour = 3;
  int _alarmMinute = 0;

  // Cycle mode state
  int _cycleIntervalMinutes = 30;
  bool _cycleHasStartTime = false;
  int _cycleStartHour = 22;
  int _cycleStartMinute = 0;
  bool _cycleHasEndTime = false;
  int _cycleEndHour = 9;
  int _cycleEndMinute = 0;

  void _start() {
    widget.onStart(TaskSetupData(
      mode: _selectedMode,
      targetHour: _selectedMode == 'recurring' ? _alarmHour : 0,
      targetMinute: _selectedMode == 'recurring' ? _alarmMinute : 0,
      durationMinutes: _selectedMode == 'countdown' ? (_selectedHour * 60) + _selectedMinute : 0,
      cycleIntervalMinutes: _cycleIntervalMinutes,
      cycleStartHour: _cycleHasStartTime ? _cycleStartHour : -1,
      cycleStartMinute: _cycleHasStartTime ? _cycleStartMinute : -1,
      cycleEndHour: _cycleHasEndTime ? _cycleEndHour : -1,
      cycleEndMinute: _cycleHasEndTime ? _cycleEndMinute : -1,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Mode tabs
      Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
        child: Row(children: [
          _modeTab('countdown', Icons.timer_outlined, AppStrings.get('countdown')),
          _modeTab('recurring', Icons.alarm_rounded, AppStrings.get('scheduled')),
          _modeTab('cycle', Icons.loop_rounded, AppStrings.get('cycle')),
        ]),
      ),
      const SizedBox(height: 24),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectedMode == 'countdown'
            ? _buildCountdownPicker(key: const ValueKey('cp'))
            : _selectedMode == 'recurring'
                ? _buildAlarmPicker(key: const ValueKey('ap'))
                : _buildCyclePicker(key: const ValueKey('cyc')),
      ),
      const SizedBox(height: 24),
      GradientButton(label: AppStrings.get('startTimer'), gradient: AppColors.accentGradient, icon: Icons.play_arrow_rounded, onTap: _start),
    ]);
  }

  Widget _modeTab(String mode, IconData icon, String label) {
    final sel = _selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: sel ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: sel ? Border.all(color: AppColors.accent.withOpacity(0.2)) : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: sel ? AppColors.accent : AppColors.textDim),
            const SizedBox(width: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, maxLines: 1, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: sel ? AppColors.textPrimary : AppColors.textDim)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Countdown Picker ──────────────────────────────────────
  Widget _buildCountdownPicker({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(AppStrings.get('quickSelect'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _presetChip('15m', 0, 15), _presetChip('30m', 0, 30), _presetChip('1h', 1, 0),
        _presetChip('1.5h', 1, 30), _presetChip('2h', 2, 0), _presetChip('3h', 3, 0), _presetChip('4h', 4, 0),
      ]),
      const SizedBox(height: 20),
      Text(AppStrings.get('customTime'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _wheelPicker(_selectedHour, 12, AppStrings.get('hour'), (v) => setState(() => _selectedHour = v)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
        _wheelPicker(_selectedMinute, 59, AppStrings.get('minute'), (v) => setState(() => _selectedMinute = v)),
      ]),
    ]);
  }

  Widget _presetChip(String label, int h, int m) {
    final sel = _selectedHour == h && _selectedMinute == m;
    return GestureDetector(
      onTap: () => setState(() { _selectedHour = h; _selectedMinute = m; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.accent.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.accent.withOpacity(0.5) : AppColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(color: sel ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }

  Widget _wheelPicker(int val, int max, String label, ValueChanged<int> onChanged) {
    return Container(
      width: 90, height: 110,
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.cardBorder)),
      child: Column(children: [
        Expanded(
          child: ListWheelScrollView.useDelegate(
            itemExtent: 38, perspective: 0.004, diameterRatio: 1.2,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: val),
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: max + 1,
              builder: (_, i) {
                if (i < 0 || i > max) return null;
                final s = i == val;
                return Center(child: Text(i.toString().padLeft(2, '0'), style: TextStyle(fontSize: s ? 22 : 16, fontWeight: s ? FontWeight.w700 : FontWeight.w400, color: s ? AppColors.accent : AppColors.textDim)));
              },
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textDim))),
      ]),
    );
  }

  // ── Alarm Picker ──────────────────────────────────────────
  Widget _buildAlarmPicker({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Text(AppStrings.get('scheduledTime'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _wheelPicker(_alarmHour, 23, AppStrings.get('hour'), (v) => setState(() => _alarmHour = v)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
        _wheelPicker(_alarmMinute, 59, AppStrings.get('minute'), (v) => setState(() => _alarmMinute = v)),
      ]),
      const SizedBox(height: 10),
      Text(AppStrings.get('scheduledDesc'), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
    ]);
  }

  // ── Cycle Picker ──────────────────────────────────────────
  Widget _buildCyclePicker({Key? key}) {
    return Column(key: key, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // ── Interval ──
      Text(AppStrings.get('cycleInterval'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text(AppStrings.get('cycleIntervalDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
      const SizedBox(height: 12),
      // Quick interval chips
      Wrap(spacing: 8, runSpacing: 8, children: [
        _cycleChip('10m', 10), _cycleChip('15m', 15), _cycleChip('20m', 20),
        _cycleChip('30m', 30), _cycleChip('45m', 45), _cycleChip('60m', 60),
        _cycleChip('90m', 90),
      ]),
      const SizedBox(height: 14),
      // Custom interval wheel
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 90, height: 110,
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accent.withOpacity(0.3))),
          child: Column(children: [
            Expanded(
              child: ListWheelScrollView.useDelegate(
                itemExtent: 38, perspective: 0.004, diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                controller: FixedExtentScrollController(initialItem: _cycleIntervalMinutes),
                onSelectedItemChanged: (v) => setState(() => _cycleIntervalMinutes = v == 0 ? 1 : v),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: 121,
                  builder: (_, i) {
                    if (i == 0) return null;
                    final s = i == _cycleIntervalMinutes;
                    return Center(child: Text('$i', style: TextStyle(fontSize: s ? 22 : 16, fontWeight: s ? FontWeight.w700 : FontWeight.w400, color: s ? AppColors.accent : AppColors.textDim)));
                  },
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(AppStrings.get('minute'), style: const TextStyle(fontSize: 10, color: AppColors.textDim))),
          ]),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${AppStrings.get('cycleEvery')} $_cycleIntervalMinutes ${AppStrings.get('cycleMin')}',
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(AppStrings.get('cycleIntervalDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
        ])),
      ]),
      const SizedBox(height: 20),
      // ── Start Time ──
      Row(children: [
        Expanded(child: Text(AppStrings.get('cycleStart'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
        Switch(
          value: _cycleHasStartTime,
          onChanged: (v) => setState(() => _cycleHasStartTime = v),
          activeColor: AppColors.accent,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ]),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _cycleHasStartTime ? Column(children: [
          const SizedBox(height: 8),
          Text(AppStrings.get('cycleStartDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _wheelPicker(_cycleStartHour, 23, AppStrings.get('hour'), (v) => setState(() => _cycleStartHour = v)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
            _wheelPicker(_cycleStartMinute, 59, AppStrings.get('minute'), (v) => setState(() => _cycleStartMinute = v)),
          ]),
        ]) : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(AppStrings.get('cycleNoStart'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        ),
      ),
      const SizedBox(height: 20),
      // ── End Time ──
      Row(children: [
        Expanded(child: Text(AppStrings.get('cycleEnd'), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
        Switch(
          value: _cycleHasEndTime,
          onChanged: (v) => setState(() => _cycleHasEndTime = v),
          activeColor: AppColors.accent,
          inactiveTrackColor: AppColors.cardBorder,
        ),
      ]),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: _cycleHasEndTime ? Column(children: [
          const SizedBox(height: 8),
          Text(AppStrings.get('cycleEndDesc'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _wheelPicker(_cycleEndHour, 23, AppStrings.get('hour'), (v) => setState(() => _cycleEndHour = v)),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text(':', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w200, color: AppColors.textDim))),
            _wheelPicker(_cycleEndMinute, 59, AppStrings.get('minute'), (v) => setState(() => _cycleEndMinute = v)),
          ]),
        ]) : Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(AppStrings.get('cycleNoEnd'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        ),
      ),
    ]);
  }

  Widget _cycleChip(String label, int minutes) {
    final sel = _cycleIntervalMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _cycleIntervalMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? AppColors.accent.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.accent.withOpacity(0.5) : AppColors.cardBorder),
        ),
        child: Text(label, style: TextStyle(color: sel ? AppColors.accent : AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}
