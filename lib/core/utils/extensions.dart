import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;

  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get backgroundColor => isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get textPrimary => isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }

  String get initials {
    final parts = trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.isNotEmpty ? parts.first[0].toUpperCase() : '';
    return '\${parts.first[0]}\${parts.last[0]}'.toUpperCase();
  }
}
