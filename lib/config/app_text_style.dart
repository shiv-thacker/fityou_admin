import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system — all text styles in one place.
abstract final class AppTextStyle {
  static const TextStyle headlineLarge = TextStyle(
    color: AppColors.textLight,
    fontWeight: FontWeight.bold,
    fontSize: 28,
  );

  static const TextStyle headlineMedium = TextStyle(
    color: AppColors.textLight,
    fontWeight: FontWeight.bold,
    fontSize: 22,
  );

  static const TextStyle titleLarge = TextStyle(
    color: AppColors.textLight,
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  static const TextStyle titleMedium = TextStyle(
    color: AppColors.textLight,
    fontSize: 16,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: AppColors.textLight,
    fontSize: 14,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: AppColors.textMuted,
    fontSize: 14,
  );

  static const TextStyle labelSmall = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );
}
