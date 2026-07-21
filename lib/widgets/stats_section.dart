import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../services/ir_platform_service.dart';
import '../theme/app_colors.dart';
import '../utils/countdown_format.dart';
import '../utils/usage_stats.dart';

/// Expandable "Usage Statistics" card, styled like ProfilesSection.
/// Loads stats lazily on first expand and after a reset.
class StatsSection extends StatefulWidget {
  final IrPlatformService service;
  final void Function(String message, Color color) onSnack;

  const StatsSection({super.key, required this.service, required this.onSnack});

  @override
  State<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends State<StatsSection> {
  bool _expanded = false;
  UsageStatsSummary? _summary;
  bool _loading = false;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final events = await widget.service.getStats();
      if (!mounted) return;
      setState(() {
        _summary = summarizeStats(events);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reset() async {
    await widget.service.resetStats();
    widget.onSnack(AppStrings.get('statsResetOk'), AppColors.success);
    await _load();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded && _summary == null) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        GestureDetector(
          onTap: _toggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.bar_chart_rounded, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(AppStrings.get('statsTitle'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary))),
              AnimatedRotation(turns: _expanded ? 0.5 : 0, duration: const Duration(milliseconds: 200), child: const Icon(Icons.expand_more, color: AppColors.textDim)),
            ]),
          ),
        ),
        if (_expanded) ...[
          const Divider(color: AppColors.cardBorder, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _loading
                ? const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: AppColors.accent)))
                : _buildBody(),
          ),
        ],
      ]),
    );
  }

  Widget _buildBody() {
    final s = _summary;
    if (s == null) return const SizedBox.shrink();
    final lastStr = s.lastTransmissionMs == null
        ? AppStrings.get('statsNever')
        : _formatDate(s.lastTransmissionMs!);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [
        _statTile(AppStrings.get('statsTotal'), '${s.totalTransmissions}'),
        const SizedBox(width: 10),
        _statTile(AppStrings.get('statsLast7'), '${s.last7Days}'),
        const SizedBox(width: 10),
        _statTile('${AppStrings.get('statsSaved')} (${AppStrings.get('statsHours')})', '~${s.estimatedSavedHours}'),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.history_rounded, size: 14, color: AppColors.textDim),
        const SizedBox(width: 6),
        Text('${AppStrings.get('statsLast')}: ', style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
        Text(lastStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 8),
      Text(AppStrings.get('statsSavedNote'), style: const TextStyle(color: AppColors.textDim, fontSize: 10, height: 1.4)),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _reset,
        icon: const Icon(Icons.restart_alt_rounded, size: 16),
        label: Text(AppStrings.get('statsReset'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: BorderSide(color: AppColors.danger.withOpacity(0.5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(0, 40),
        ),
      ),
    ]);
  }

  Widget _statTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.cardBorder)),
        child: Column(children: [
          Text(value, style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textDim, fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  String _formatDate(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final d = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    return '$d  ${formatHmFromEpoch(epochMs)}';
  }
}
