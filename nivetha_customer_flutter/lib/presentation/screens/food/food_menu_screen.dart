
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/food_model.dart';
import '../../../data/repositories/food_repository.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import 'food_details_screen.dart';

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  State<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  List<FoodModel> _foods = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result =
          await FoodRepository.instance.getAvailableFoods();

      if (!mounted) return;

      setState(() {
        _foods = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load the menu. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<String> get _categories {
    final values = _foods
        .map((food) => food.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return ['All', ...values];
  }

  List<FoodModel> get _filteredFoods {
    final query = _searchController.text.trim().toLowerCase();

    return _foods.where((food) {
      final matchesCategory = _selectedCategory == 'All' ||
          food.category == _selectedCategory;

      final matchesSearch = query.isEmpty ||
          food.name.toLowerCase().contains(query) ||
          food.tamilName.toLowerCase().contains(query) ||
          food.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Our Food Menu'),
        actions: [
          IconButton(
            onPressed: _loadFoods,
            tooltip: 'Refresh menu',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search food / உணவை தேடுங்கள்',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                ),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: AppColors.border,
                  ),
                ),
              ),
            ),
          ),
          if (!_isLoading && _error == null && _foods.isNotEmpty)
            _buildCategories(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGreenDark,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.restaurant_menu_rounded,
            color: AppColors.goldAccent,
            size: 38,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discover Our Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'சுவையான உணவுகள் உங்கள் நிகழ்ச்சிக்கு',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = _categories;

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = 'All';
    }

    return SizedBox(
      height: 53,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = category == _selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) {
              setState(() => _selectedCategory = category);
            },
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(
        message: 'Loading food menu...',
      );
    }

    if (_error != null) {
      return ErrorStateWidget(
        title: 'Menu Unavailable',
        message: _error!,
        onRetry: _loadFoods,
      );
    }

    if (_foods.isEmpty) {
      return EmptyStateWidget(
        title: 'No Food Items Yet',
        message:
            'Our menu items will appear here when they become available.',
        icon: Icons.restaurant_outlined,
        buttonText: 'Refresh',
        onButtonPressed: _loadFoods,
      );
    }

    final foods = _filteredFoods;

    if (foods.isEmpty) {
      return EmptyStateWidget(
        title: 'No Matching Food',
        message:
            'Try another search term or choose a different category.',
        icon: Icons.search_off_rounded,
        buttonText: 'Clear Filters',
        onButtonPressed: () {
          _searchController.clear();
          setState(() => _selectedCategory = 'All');
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFoods,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.69,
        ),
        itemCount: foods.length,
        itemBuilder: (context, index) {
          return _foodCard(foods[index]);
        },
      ),
    );
  }

  Widget _foodCard(FoodModel food) {
    final isNonVeg = food.type.toLowerCase().contains('non');

    final typeColor =
        isNonVeg ? AppColors.nonVeg : AppColors.veg;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FoodDetailsScreen(food: food),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    food.image.trim().isEmpty
                        ? Container(
                            color: AppColors.primaryGreenLight,
                            child: const Icon(
                              Icons.restaurant_rounded,
                              size: 55,
                              color: AppColors.primary,
                            ),
                          )
                        : Image.network(
                            food.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: AppColors.primaryGreenLight,
                                child: const Icon(
                                  Icons.restaurant_rounded,
                                  size: 55,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primaryGreenDark,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (food.tamilName.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          food.tamilName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        food.category.isEmpty
                            ? 'Nivetha Catering'
                            : food.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'View Details',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppColors.primary,
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
