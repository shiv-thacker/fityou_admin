import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_size.dart';
import 'app_text_style.dart';

/// Material [ThemeData] built entirely from design tokens.
/// No raw colour literals here — always reference [AppColors].
abstract final class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          onPrimary: Colors.white,
          secondary: AppColors.card,
        ),
        scaffoldBackgroundColor: AppColors.primary,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textLight,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSize.lg, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.radiusMd)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.radiusMd),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.radiusMd),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSize.radiusMd),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textMuted),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge:  AppTextStyle.headlineLarge,
          headlineMedium: AppTextStyle.headlineMedium,
          titleLarge:     AppTextStyle.titleLarge,
          titleMedium:    AppTextStyle.titleMedium,
          bodyLarge:      AppTextStyle.bodyLarge,
          bodyMedium:     AppTextStyle.bodyMedium,
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.white12,
          thickness: 1,
        ),
      );
}
