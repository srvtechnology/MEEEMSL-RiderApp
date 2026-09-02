import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTextStyles provides consistent typographic hierarchy
/// based on Inter and Poppins fonts.
class AppTextStyles {
  AppTextStyles._();

  // Display Styles (for big splash, big numbers)
  static TextStyle displayLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: -0.5,
      );

  // Headline Styles (for screen headers, major cards)
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle headlineMedium({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle headlineSmall({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  // Title Styles (section headers, list item titles)
  static TextStyle titleLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimaryLight,
      );

  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimaryLight,
      );

  // Body Styles (regular text, descriptions)
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimaryLight,
        height: 1.4,
      );

  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondaryLight,
        height: 1.4,
      );

  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondaryLight,
        height: 1.3,
      );

  // Label Styles (buttons, tabs, chips, badges)
  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: 0.2,
      );

  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryLight,
        letterSpacing: 0.2,
      );

  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textSecondaryLight,
        letterSpacing: 0.3,
      );

  // Domain Specific Typography
  static TextStyle earningsAmount({Color? color, double fontSize = 28}) =>
      GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle orderTimer({Color? color}) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.secondary,
      );

  static TextStyle navigationEta({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryLight,
      );
}
