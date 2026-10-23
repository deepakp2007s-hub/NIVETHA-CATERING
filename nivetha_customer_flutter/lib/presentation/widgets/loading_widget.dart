
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final String message;
  final double indicatorSize;
  final bool showMessage;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message = 'Please wait...',
    this.indicatorSize = 38,
    this.showMessage = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor = color ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: indicatorSize + 30,
              height: indicatorSize + 30,
              decoration: BoxDecoration(
                color: AppColors.primaryGreenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: indicatorSize,
                height: indicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: indicatorColor,
                  backgroundColor: AppColors.goldAccent.withValues(
                    alpha: 0.35,
                  ),
                ),
              ),
            ),
            if (showMessage) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
