import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({
    super.key,
    this.title = 'NIVETHA Catering',
    this.subtitle = 'FUNCTION CATERING',
    this.onNotificationTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: AppColors.accentGradient,
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.background,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'BodoniModa',
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.4,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: onNotificationTap,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.18),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.textPrimary,
                  size: 23,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
