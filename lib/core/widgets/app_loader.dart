import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

/// Centered loading indicator using the app accent colour.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
