import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.error,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
