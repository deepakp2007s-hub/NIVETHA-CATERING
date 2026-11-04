import 'package:flutter/material.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/food_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<FoodModel>> _foodsFuture;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Sweets',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchMenu() {
    _foodsFuture = _foodService.getFoods(
      category: _selectedCategory == 'All' ? null : _selectedCategory,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _fetchMenu();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
      _fetchMenu();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Food Catalog',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search dishes (e.g., Meals, Sweets)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Horizontal Categories Filter Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => _onCategorySelected(cat),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 16),

          // Food Catalog List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _fetchMenu();
                });
              },
              child: FutureBuilder<List<FoodModel>>(
                future: _foodsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Failed to load menu.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final foods = snapshot.data ?? [];

                  if (foods.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.no_food_outlined,
                                size: 56, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No matching dishes found.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Try selecting a different category or clearing search.',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final item = foods[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.restaurant_menu,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (item.category.isNotEmpty)
                                      Text(
                                        item.category,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    if (item.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (item.isAvailable)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Available',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}