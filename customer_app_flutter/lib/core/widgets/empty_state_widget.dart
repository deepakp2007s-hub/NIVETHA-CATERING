import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'primary_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.deepGreen),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.luxuryGold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: buttonText!,
                onPressed: onButtonPressed!,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}