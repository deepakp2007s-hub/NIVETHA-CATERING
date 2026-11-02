import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/image_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/food_model.dart';
import '../../../shared/widgets/app_media_image.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../../foods/providers/food_catalog_provider.dart';
import '../../foods/widgets/food_card.dart';
import '../widgets/service_card.dart';
import '../widgets/welcome_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenMenus,
    this.onOpenBookings,
  });

  final VoidCallback? onOpenMenus;
  final VoidCallback? onOpenBookings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();

  static const _functionCategories = [
    {'title': 'Wedding', 'subtitle': 'Ceremonial catering', 'icon': Icons.favorite_rounded},
    {'title': 'Engagement', 'subtitle': 'Intimate celebrations', 'icon': Icons.diamond_outlined},
    {'title': 'Birthday', 'subtitle': 'Family gatherings', 'icon': Icons.cake_outlined},
    {'title': 'House Function', 'subtitle': 'Home events', 'icon': Icons.home_outlined},
    {'title': 'Corporate Event', 'subtitle': 'Office functions', 'icon': Icons.business_center_outlined},
    {'title': 'Temple Function', 'subtitle': 'Traditional service', 'icon': Icons.temple_hindu_outlined},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final catalog = context.watch<FoodCatalogProvider>();
    final query = _searchController.text;
    final featured = catalog.search(query).take(6).toList();
    final banners = ImageConfig.bannerAssets;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: catalog.load,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              WelcomeHeader(
                title: auth.customer?.name.isNotEmpty == true
                    ? 'Hello, ${auth.customer!.name.split(' ').first}'
                    : 'NIVETHA Catering',
                subtitle: 'FUNCTION CATERING',
                onNotificationTap: () {
                  Navigator.pushNamed(context, AppRouter.notifications);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search published menus',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
              if (banners.isNotEmpty) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 170,
                  child: PageView.builder(
                    itemCount: banners.length,
                    controller: PageController(viewportFraction: 0.9),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AppMediaImage(assetPath: banners[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 28),
              _sectionTitle('Function categories'),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _functionCategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final category = _functionCategories[index];
                    return ServiceCard(
                      title: category['title'] as String,
                      subtitle: category['subtitle'] as String,
                      icon: category['icon'] as IconData,
                      imageAsset: ImageConfig.categoryAsset(
                        category['title'] as String,
                      ),
                      onTap: widget.onOpenBookings,
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _sectionTitle(
                'Published menus',
                action: 'View all',
                onAction: widget.onOpenMenus,
              ),
              _buildMenuSection(catalog, featured),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book catering for your function',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Submit a function catering request. NIVETHA confirms every booking before it is scheduled.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.eventType);
                        },
                        child: const Text('Start booking request'),
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

  Widget _sectionTitle(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'BodoniModa',
                fontSize: 22,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    FoodCatalogProvider catalog,
    List<FoodItem> featured,
  ) {
    if (catalog.isLoading && catalog.foods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            ShimmerBox(height: 160),
            SizedBox(height: 12),
            ShimmerBox(height: 160),
          ],
        ),
      );
    }

    if (catalog.errorMessage != null && catalog.foods.isEmpty) {
      return AppErrorView(
        message: catalog.errorMessage!,
        onRetry: catalog.load,
      );
    }

    if (featured.isEmpty) {
      return const EmptyState(
        title: 'Menus will appear here',
        message:
            'No published dishes are available yet. This catalog stays empty until NIVETHA adds real menu items.',
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: featured.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final food = featured[index];
          return FoodCard(
            food: food,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.foodDetails,
                arguments: food,
              );
            },
          );
        },
      ),
    );
  }
}
