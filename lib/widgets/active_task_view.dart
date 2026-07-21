import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../utils/countdown_format.dart';
import 'glow_ring_painter.dart';
import 'gradient_button.dart';

class ActiveTaskView extends StatelessWidget {
  final Map<String, dynamic> task;
  final String timeRemainingStr;
  final double progress;
  final Animation<double> pulseAnimation;
  final VoidCallback onCancel;

  const ActiveTaskView({
    super.key,
    required this.task,
    required this.timeRemainingStr,
    required this.progress,
    required this.pulseAnimation,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final mode = task['mode'] ?? '';
    final int cycleEndEpoch = task['cycleEndEpochMillis'] ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withOpacity(0.15)),
        boxShadow: [BoxShadow(color: AppColors.accent.withOpacity(0.05), blurRadius: 30, spreadRadius: 5)],
      ),
      child: Column(children: [
        Text(
          mode == 'countdown' ? AppStrings.get('countdownActive')
              : mode == 'cycle' ? AppStrings.get('cycleActive')
              : AppStrings.get('recurringActive'),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 200, height: 200,
          child: AnimatedBuilder(
            animation: pulseAnimation,
            builder: (_, __) => CustomPaint(
              painter: GlowRingPainter(progress: progress, color: AppColors.accent, glowIntensity: 0.2 + 0.2 * pulseAnimation.value),
              child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(timeRemainingStr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: mode == 'countdown' || mode == 'cycle' ? 28 : 18,
                      fontWeight: FontWeight.w300, color: AppColors.textPrimary, letterSpacing: 2)),
                const SizedBox(height: 4),
                if (mode == 'countdown') Text(AppStrings.get('remaining'), style: const TextStyle(color: AppColors.textDim, fontSize: 11))
                else if (mode == 'cycle') ...[Text(AppStrings.get('nextSignal'), style: const TextStyle(color: AppColors.textDim, fontSize: 10)),
                  if (cycleEndEpoch > 0) ...[const SizedBox(height: 4),
                    Text('${AppStrings.get('cycleUntil')} ${formatHmFromEpoch(cycleEndEpoch)}', style: const TextStyle(color: AppColors.warning, fontSize: 10))]]
                else if (mode == 'recurring') Text(AppStrings.get('everyDay'), style: const TextStyle(color: AppColors.textDim, fontSize: 11)),
              ])),
            ),
          ),
        ),
        const SizedBox(height: 32),
        GradientButton(label: AppStrings.get('cancelTimer'), gradient: AppColors.dangerGradient, icon: Icons.close, onTap: onCancel),
      ]),
    );
  }
}
