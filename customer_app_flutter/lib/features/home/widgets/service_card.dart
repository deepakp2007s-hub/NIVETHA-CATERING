import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_media_image.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({
    super.key,
    required this.title,
    this.subtitle = '',
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.imageAsset,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? imageAsset;

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    final hasImage =
        widget.imageAsset != null && widget.imageAsset!.trim().isNotEmpty;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: 0.16),
              width: selected ? 1.4 : 0.8,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                AppMediaImage(assetPath: widget.imageAsset, icon: widget.icon),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hasImage)
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceVariant,
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 22,
                          color: selected ? AppColors.gold : AppColors.primary,
                        ),
                      ),
                    if (!hasImage) const SizedBox(height: 10),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (widget.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
