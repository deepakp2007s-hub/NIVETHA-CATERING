import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/food_model.dart';
import '../../../shared/widgets/app_media_image.dart';
import '../../../shared/widgets/glass_card.dart';
import '../providers/food_catalog_provider.dart';
import '../widgets/food_card.dart';

class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final food = ModalRoute.of(context)?.settings.arguments;
    if (food is! FoodItem) {
      return const Scaffold(
        body: Center(child: Text('Menu item is unavailable.')),
      );
    }

    final related = context.watch<FoodCatalogProvider>().relatedTo(food);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: AppMediaImage(
                networkUrl: food.imageUrl,
                assetPath: food.localAsset,
                heroTag: 'food-image-${food.id}',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (food.category.isNotEmpty)
                    Text(
                      food.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.gold,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    food.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    food.isAvailable
                        ? 'Available for function catering'
                        : 'Currently unavailable',
                    style: TextStyle(
                      color: food.isAvailable
                          ? AppColors.success
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  GlassCard(
                    child: Text(
                      food.description.isEmpty
                          ? 'Details for this dish will appear when NIVETHA publishes a description.'
                          : food.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Related menus',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: related.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = related[index];
                          return SizedBox(
                            width: 180,
                            child: FoodCard(
                              food: item,
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRouter.foodDetails,
                                  arguments: item,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
