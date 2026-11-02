import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/food_catalog_provider.dart';
import '../widgets/food_card.dart';

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<FoodCatalogProvider>();
    final items = catalog.search(
      _searchController.text,
      category: _selectedCategory,
    );
    final categories = ['All', ...catalog.categories];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menus',
                    style: TextStyle(
                      fontFamily: 'BodoniModa',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Explore NIVETHA catering dishes from the live catalog.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search menus',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            if (catalog.categories.isNotEmpty)
              SizedBox(
                height: 54,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final selected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedCategory = category);
                      },
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: selected
                            ? AppColors.background
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: AppColors.surface,
                    );
                  },
                ),
              ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: catalog.load,
                child: _buildBody(catalog, items),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FoodCatalogProvider catalog, List items) {
    if (catalog.isLoading && catalog.foods.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          ShimmerBox(height: 180),
          SizedBox(height: 12),
          ShimmerBox(height: 180),
        ],
      );
    }

    if (catalog.errorMessage != null && catalog.foods.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          AppErrorView(
            message: catalog.errorMessage!,
            onRetry: catalog.load,
          ),
        ],
      );
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          EmptyState(
            title: 'No menus to display',
            message:
                'The live catalog is empty. Dishes will appear here when they are published by NIVETHA.',
            icon: Icons.restaurant_outlined,
          ),
        ],
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final food = items[index];
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
    );
  }
}
