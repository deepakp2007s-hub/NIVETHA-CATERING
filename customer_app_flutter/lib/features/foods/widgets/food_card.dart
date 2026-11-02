import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/food_model.dart';
import '../../../shared/widgets/app_media_image.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    this.onTap,
  });

  final FoodItem food;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: AspectRatio(
                  aspectRatio: 1.25,
                  child: AppMediaImage(
                    networkUrl: food.imageUrl,
                    assetPath: food.localAsset,
                    heroTag: 'food-image-${food.id}',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (food.category.isNotEmpty)
                      Text(
                        food.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      food.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (food.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      food.isAvailable ? 'Available' : 'Unavailable',
                      style: TextStyle(
                        color: food.isAvailable
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
