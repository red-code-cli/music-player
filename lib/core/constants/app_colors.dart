import 'package:flutter/material.dart';

/// Apple Music Dark Color Palette
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color surfaceElevated = Color(0xFF2C2C2E);
  static const Color surfaceHover = Color(0xFF3A3A3C);

  // Brand / Accents
  static const Color accent = Color(0xFFFA2D48); // Apple Music Red-Pink
  static const Color accentSecondary = Color(0xFFFF375F);
  static const Color accentSubtle = Color(0x33FA2D48);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF636366);

  // Dividers & Borders
  static const Color divider = Color(0xFF262629);
  static const Color border = Color(0xFF38383A);

  // Glassmorphic translucent surfaces
  static const Color glassBackground = Color(0xCC141416);
  static const Color glassBorder = Color(0x22FFFFFF);

  // Status & Feedback
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color error = Color(0xFFFF453A);
}
