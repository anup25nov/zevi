import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.inkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.violetDim,
        primaryContainer: AppColors.violet,
        surface: AppColors.inkBg,
        surfaceContainerHighest: AppColors.surfaceHighest,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ashBg,
    );
  }
}
