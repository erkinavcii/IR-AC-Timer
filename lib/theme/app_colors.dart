import 'package:flutter/material.dart';

class AppColors {
  static const Color bg = Color(0xFF05050A);
  static const Color card = Color(0xFF0D0D14);
  static const Color cardBackground = card;
  static const Color cardBorder = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF12121C);
  static const Color accent = Color(0xFF00D4FF);
  static const Color primary = accent;
  static const Color accentDim = Color(0xFF0A3D4F);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFFF5252);
  static const Color textPrimary = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color textDim = Color(0xFF555570);

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFF1744)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D0D14), Color(0xFF10101A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
