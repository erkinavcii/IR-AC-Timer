import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';

class XiaomiCard extends StatelessWidget {
  final VoidCallback onOpenAutostart;

  const XiaomiCard({super.key, required this.onOpenAutostart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.15)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Text(AppStrings.get('xiaomiWarning'), style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.warning.withOpacity(0.9), fontSize: 12)),
        ]),
        const SizedBox(height: 8),
        Text(AppStrings.get('xiaomiDesc'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onOpenAutostart,
          child: Container(
            height: 36,
            decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.warning.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.settings_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(AppStrings.get('openAutostart'), style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 11)),
            ]),
          ),
        ),
      ]),
    );
  }
}
