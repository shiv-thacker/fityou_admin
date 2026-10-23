import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Convenient [BuildContext] helpers available everywhere in the UI.
extension BuildContextX on BuildContext {
  ThemeData   get theme       => Theme.of(this);
  TextTheme   get textTheme   => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  Size   get screenSize   => MediaQuery.sizeOf(this);
  double get screenWidth  => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
      ),
    );
  }
}
