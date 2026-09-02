import 'package:flutter/material.dart';

/// AppColors defines the complete design system color palette
/// derived from the primary brand color #0834C2 (Electric Sapphire).
class AppColors {
  AppColors._();

  // Primary Brand Palette (#0834C2)
  static const Color primary = Color(0xFF0834C2);
  static const Color primaryLight = Color(0xFF3B64E6);
  static const Color primaryDark = Color(0xFF052382);
  static const Color primaryContainer = Color(0xFFE8EEFF);
  static const Color onPrimaryContainer = Color(0xFF00164D);

  // Material 3 Swatch for #0834C2
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0834C2,
    <int, Color>{
      50: Color(0xFFEFF3FF),
      100: Color(0xFFDBE4FE),
      200: Color(0xFFBFD0FE),
      300: Color(0xFF93B2FD),
      400: Color(0xFF608DFC),
      500: Color(0xFF0834C2), // Base
      600: Color(0xFF2448F5),
      700: Color(0xFF1B36DE),
      800: Color(0xFF162BB4),
      900: Color(0xFF18298E),
    },
  );

  // Secondary Accent Palette (#FF6B00 - Warm Amber/Orange for CTAs & Actions)
  static const Color secondary = Color(0xFFFF6B00);
  static const Color secondaryLight = Color(0xFFFF8B3D);
  static const Color secondaryDark = Color(0xFFCC5500);
  static const Color secondaryContainer = Color(0xFFFFECE0);
  static const Color onSecondaryContainer = Color(0xFF4D2000);

  // Semantic Status Colors
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F8EE);
  static const Color successDark = Color(0xFF009624);

  static const Color warning = Color(0xFFFFA000);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color warningDark = Color(0xFFC67C00);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFB91C1C);

  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color infoDark = Color(0xFF0369A1);

  // Light Theme Surfaces & Backgrounds
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF1E293B);

  // Neutral Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Neutral Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);

  // UI Component Specifics
  static const Color onlineGreen = Color(0xFF10B981);
  static const Color offlineGray = Color(0xFF94A3B8);
  static const Color mapPolyline = Color(0xFF0834C2);
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0834C2), Color(0xFF2448F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF8B3D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient onlineGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFF0834C2), Color(0xFF1B36DE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
