
import 'package:flutter/material.dart';

import '../../../data/models/food_model.dart';
import '../../../data/repositories/food_repository.dart';
import 'food_details_screen.dart';

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  State<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  final FoodRepository _repository = FoodRepository();

  final TextEditingController _searchController =
      TextEditingController();

  late final AnimationController _animationController;

  List<FoodModel> _foods = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = const [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
    'Sweets',
    'Drinks',
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _searchController.addListener(_onSearchChanged);
    _loadFoods();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return;

    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  Future<void> _loadFoods() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final foods = await _repository.getFoods();

      if (!mounted) return;

      setState(() {
        _foods = foods;
        _isLoading = false;
      });

      _animationController
        ..reset()
        ..forward();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load food menu. Please try again.';
      });
    }
  }

  List<FoodModel> get _filteredFoods {
    return _foods.where((food) {
      final categoryMatches = _selectedCategory == 'All' ||
          food.category.toLowerCase() ==
              _selectedCategory.toLowerCase();

      final query = _searchQuery;

      final searchMatches = query.isEmpty ||
          food.name.toLowerCase().contains(query) ||
          food.tamilName.toLowerCase().contains(query) ||
          food.category.toLowerCase().contains(query) ||
          food.description.toLowerCase().contains(query);

      return categoryMatches && searchMatches && food.available;
    }).toList();
  }

  void _openFoodDetails(FoodModel food) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodDetailsScreen(food: food),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          onRefresh: _loadFoods,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  child: _buildHeader(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchBox(),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 76,
                  child: _buildCategoryFilters(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 15),
                  child: _buildResultsHeader(),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: gold,
                    ),
                  ),
                )
              else if (_errorMessage != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else if (_filteredFoods.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final food = _filteredFoods[index];

                        return _FoodCard(
                          key: ValueKey(food.id.isNotEmpty
                              ? food.id
                              : '${food.name}-$index'),
                          food: food,
                          index: index,
                          onTap: () => _openFoodDetails(food),
                        );
                      },
                      childCount: _filteredFoods.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.68,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFE9DFD0)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: navy,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Our Food Menu',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: navy,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'சுவையான உணவு வகைகள்',
                style: TextStyle(
                  color: Color(0xFF9B762D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE6A2), gold],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            color: navy,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search food / உணவு தேடுங்கள்',
          hintStyle: TextStyle(
            color: Colors.blueGrey.shade300,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: gold,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.close_rounded),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: Color(0xFFECE3D6),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: gold,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 17,
      ),
      scrollDirection: Axis.horizontal,
      itemCount: _categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 9),
      itemBuilder: (context, index) {
        final category = _categories[index];
        final selected = _selectedCategory == category;

        return ChoiceChip(
          label: Text(category),
          selected: selected,
          onSelected: (_) {
            setState(() => _selectedCategory = category);
          },
          backgroundColor: Colors.white,
          selectedColor: navy,
          side: BorderSide(
            color: selected ? navy : const Color(0xFFE8DECE),
          ),
          labelStyle: TextStyle(
            color: selected ? Colors.white : navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 5,
          ),
        );
      },
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Discover Delicious Food',
            style: TextStyle(
              color: navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            '${_filteredFoods.length} items',
            style: const TextStyle(
              color: Color(0xFF8A641C),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 58,
              color: Color(0xFFB77B25),
            ),
            const SizedBox(height: 15),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: navy,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadFoods,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.no_food_rounded,
                size: 43,
                color: gold,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No food found',
              style: TextStyle(
                color: navy,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'வேறு category அல்லது search முயற்சி செய்யுங்கள்.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'All';
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoodCard extends StatefulWidget {
  final FoodModel food;
  final int index;
  final VoidCallback onTap;

  const _FoodCard({
    super.key,
    required this.food,
    required this.index,
    required this.onTap,
  });

  @override
  State<_FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<_FoodCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _pressed = false;

  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() => _pressed = value);

    if (value) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.965 : 1,
        duration: const Duration(milliseconds: 160),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOut,
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFECE3D5),
              ),
              boxShadow: [
                BoxShadow(
                  color: navy.withValues(alpha: 0.07),
                  blurRadius: 15,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 11,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: const Color(0xFFF4EBDD),
                        child: _foodImage(food.image),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            food.category.isEmpty
                                ? 'Food'
                                : food.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: navy,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 9,
                        right: 9,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: navy.withValues(alpha: 0.13),
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_outward_rounded,
                            size: 18,
                            color: navy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (food.tamilName.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            food.tamilName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF987022),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                food.price > 0
                                    ? '₹${food.price.toStringAsFixed(0)}'
                                    : 'Price on request',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: navy,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.star_rounded,
                              color: gold,
                              size: 17,
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
      ),
    );
  }

  Widget _foodImage(String image) {
    if (image.trim().isEmpty) {
      return const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 52,
          color: Color(0xFFB9A37E),
        ),
      );
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.restaurant_rounded,
            size: 52,
            color: Color(0xFFB9A37E),
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: gold,
            ),
          ),
        );
      },
    );
  }
}
