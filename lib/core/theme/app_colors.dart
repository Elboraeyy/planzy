import 'package:flutter/material.dart';

class AppColors {
  // ──────────────────────────────────────────────────────────────
  // shadcn Zinc Color Palette
  // ──────────────────────────────────────────────────────────────
  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // Surfaces & Base
  static const Color background = Color(0xFFFAFAFA); // Clean off-white zinc-50
  static const Color surface = Color(0xFFFFFFFF);    // Pure white card surfaces
  static const Color card = Color(0xFFFFFFFF);
  static const Color white = Colors.white;

  // Primary Actions (shadcn solid black default)
  static const Color primary = zinc950;
  static const Color primaryForeground = zinc50;

  // Secondary & Muted Elements
  static const Color secondary = zinc100;
  static const Color secondaryForeground = zinc900;
  static const Color muted = zinc100;
  static const Color mutedForeground = zinc500;

  // Typography
  static const Color textDark = zinc950;
  static const Color textLight = zinc500;
  static const Color textMuted = zinc400;

  // Borders & Dividers (crisp 1px hair-lines)
  static const Color border = zinc200;
  static const Color borderSubtle = zinc100;
  static const Color input = zinc200;
  static const Color ring = zinc950;

  // Fintech Accents (Subtle, elegant)
  static const Color success = Color(0xFF10B981);         // Emerald 500
  static const Color successLight = Color(0xFFECFDF5);    // Emerald 50
  static const Color destructive = Color(0xFFEF4444);     // Red 500
  static const Color destructiveLight = Color(0xFFFEF2F2);// Red 50
  static const Color accentBlue = Color(0xFF3B82F6);      // Blue 500
  static const Color accentBlueLight = Color(0xFFEFF6FF);
  static const Color accentPurple = Color(0xFF8B5CF6);    // Purple 500
  static const Color accentAmber = Color(0xFFF59E0B);     // Amber 500
  static const Color accentAmberLight = Color(0xFFFFFBEB);

  // Compatibility aliases for existing screens
  static const Color cardYellow = Color(0xFFFEF9C3); // subtle warm light amber
  static const Color cardBlue = Color(0xFFEFF6FF);   // subtle soft light blue
  static const Color tertiary = zinc900;
}
