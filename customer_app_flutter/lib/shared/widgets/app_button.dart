import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    if (outlined) {
      return OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: child,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: onPressed == null || loading ? null : AppColors.accentGradient,
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null || loading
              ? AppColors.surfaceVariant
              : Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}
