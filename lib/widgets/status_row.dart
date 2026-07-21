import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';

class StatusRow extends StatelessWidget {
  final bool hasIr;
  final bool exactAlarmGranted;
  final bool batteryOptimizationIgnored;
  final VoidCallback onRequestExactAlarm;
  final VoidCallback onRequestIgnoreBattery;

  const StatusRow({
    super.key,
    required this.hasIr,
    required this.exactAlarmGranted,
    required this.batteryOptimizationIgnored,
    required this.onRequestExactAlarm,
    required this.onRequestIgnoreBattery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _statusItem(AppStrings.get('irEmitter'), hasIr ? AppStrings.get('available') : AppStrings.get('unavailable'), hasIr ? AppColors.success : AppColors.danger, null),
          _statusDivider(),
          _statusItem(AppStrings.get('exactAlarm'), exactAlarmGranted ? AppStrings.get('active') : AppStrings.get('grantPerm'), exactAlarmGranted ? AppColors.success : AppColors.warning, exactAlarmGranted ? null : onRequestExactAlarm),
          _statusDivider(),
          _statusItem(AppStrings.get('dozeBattery'), batteryOptimizationIgnored ? AppStrings.get('batteryExempt') : AppStrings.get('disablePerm'), batteryOptimizationIgnored ? AppColors.success : AppColors.warning, batteryOptimizationIgnored ? null : onRequestIgnoreBattery),
        ],
      ),
    );
  }

  Widget _statusItem(String label, String value, Color color, VoidCallback? onTap) {
    final child = Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textDim, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(value, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
        ),
      ],
    );
    return Expanded(child: onTap != null ? GestureDetector(onTap: onTap, child: child) : child);
  }

  Widget _statusDivider() => Container(width: 1, height: 32, color: AppColors.cardBorder, margin: const EdgeInsets.symmetric(horizontal: 4));
}
