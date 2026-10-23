import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_size.dart';

/// Primary button with built-in loading state.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSize.buttonHeight,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}

/// Small icon button used in table / card action columns.
class AppActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const AppActionButton({
    super.key,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSize.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(AppSize.radiusSm),
          ),
          child: Icon(icon, size: AppSize.iconSm, color: color),
        ),
      ),
    );
  }
}

/// Danger-style delete button (red accent).
class AppDeleteButton extends StatelessWidget {
  final VoidCallback onTap;
  const AppDeleteButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => AppActionButton(
        icon: Icons.delete_outline,
        color: AppColors.danger,
        tooltip: 'Delete',
        onTap: onTap,
      );
}

/// Edit button (accent colour).
class AppEditButton extends StatelessWidget {
  final VoidCallback onTap;
  const AppEditButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => AppActionButton(
        icon: Icons.edit_outlined,
        color: AppColors.accent,
        tooltip: 'Edit',
        onTap: onTap,
      );
}
