import 'package:flutter/material.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/food_service.dart';

class FoodsScreen extends StatefulWidget {
  const FoodsScreen({super.key});

  @override
  State<FoodsScreen> createState() => _FoodsScreenState();
}

class _FoodsScreenState extends State<FoodsScreen> {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<FoodModel>> _foodsFuture;
  String _searchQuery = '';

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

  void _loadFoods() {
    _foodsFuture = _foodService.getFoods(
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim();
      _loadFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Food Items',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search food items...',
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _loadFoods();
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
                          'Failed to load foods.\n${snapshot.error}',
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
                            Icon(Icons.restaurant_outlined, size: 56, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No food items available.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.restaurant_menu,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.category.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0, bottom: 4.0),
                                  child: Text(
                                    item.category,
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (item.description.isNotEmpty)
                                Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                            ],
                          ),
                          trailing: item.isAvailable
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                )
                              : null,
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