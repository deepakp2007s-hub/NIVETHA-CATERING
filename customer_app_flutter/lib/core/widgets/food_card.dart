import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final bool isVeg;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  const FoodCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.isVeg,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.luxuryGold.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.deepGreen,
                                child: const Icon(Icons.fastfood, color: AppColors.luxuryGold, size: 32),
                              ),
                            )
                          : Container(
                              color: AppColors.deepGreen,
                              child: const Icon(Icons.fastfood, color: AppColors.luxuryGold, size: 32),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.darkForestGreen.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isVeg ? Colors.green : AppColors.errorRed,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: isVeg ? Colors.green : AppColors.errorRed,
                        ),
                      ),
                    ),
                    if (onFavoriteTap != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onFavoriteTap,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.darkForestGreen.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isFavorite ? AppColors.errorRed : AppColors.cream,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cream,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColors.luxuryGold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}