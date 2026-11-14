import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/food_model.dart';

/// Service managing the catering food catalog, dishes, and categories.
class FoodService {
  static final FoodService _instance = FoodService._internal();
  factory FoodService() => _instance;

  final Dio _dio = DioClient().dio;

  FoodService._internal();

  /// Retrieve the list of food dishes with optional filters
  Future<List<FoodModel>> getFoods({
    String? category,
    String? search,
    bool? availableOnly,
    bool? vegetarianOnly,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (category != null &&
          category.trim().isNotEmpty &&
          category.toLowerCase() != 'all') {
        queryParams['category'] = category.trim();
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (availableOnly == true) {
        queryParams['available_only'] = true;
      }

      if (vegetarianOnly == true) {
        queryParams['vegetarian_only'] = true;
      }

      final response = await _dio.get(
        ApiConfig.foods,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['foods'] ?? []);

        final foods = items.map((json) => FoodModel.fromJson(json)).toList();

        // If backend returned dishes, return them
        if (foods.isNotEmpty) {
          return foods;
        }
      }

      // If backend has no dishes seeded yet or empty response, provide default catalog
      return _getCuratedFallbackFoods(
        category: category,
        search: search,
        vegetarianOnly: vegetarianOnly,
      );
    } catch (e) {
      // In case of network error or server spin-up, provide authentic catering fallback catalog
      return _getCuratedFallbackFoods(
        category: category,
        search: search,
        vegetarianOnly: vegetarianOnly,
      );
    }
  }

  /// Retrieve a specific food dish by its ID
  Future<FoodModel> getFoodById(String foodId) async {
    try {
      final response = await _dio.get('${ApiConfig.foods}/$foodId');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['food'] ?? response.data)
            : response.data;
        return FoodModel.fromJson(data);
      }
      throw Exception('Food item not found.');
    } catch (e) {
      // Fallback search in curated catalog
      final fallbacks = _getCuratedFallbackFoods();
      for (final food in fallbacks) {
        if (food.id == foodId) return food;
      }
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Curated authentic South and North Indian catering catalog items
  List<FoodModel> _getCuratedFallbackFoods({
    String? category,
    String? search,
    bool? vegetarianOnly,
  }) {
    final List<FoodModel> catalog = [
      FoodModel(
        id: '672000000000000000000001',
        name: 'Royal Chettinad Biryani',
        category: 'Lunch',
        description:
            'Aromatic Seeraga Samba rice simmered with rich traditional Chettinad spices, fresh mint, and tender mutton or chicken.',
        imageUrl:
            'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: false,
        price: 320.0,
      ),
      FoodModel(
        id: '672000000000000000000002',
        name: 'Traditional South Indian Kalyana Meals',
        category: 'Lunch',
        description:
            'Full banana leaf grand feast including Sambar, Rasam, Mor Kuzhambu, Poriyal, Kootu, Appalam, Vada, and Payasam.',
        imageUrl:
            'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 260.0,
      ),
      FoodModel(
        id: '672000000000000000000003',
        name: 'Ghee Podi Idli & Medu Vada Combo',
        category: 'Breakfast',
        description:
            'Piping hot mini button idlis coated in golden spiced gunpowder ghee, paired with crispy golden medu vada and trio chutneys.',
        imageUrl:
            'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 140.0,
      ),
      FoodModel(
        id: '672000000000000000000004',
        name: 'Mysore Masala Dosa',
        category: 'Breakfast',
        description:
            'Crispy golden fermented crepe layered with fiery red garlic-chili paste and stuffed with spiced potato masala.',
        imageUrl:
            'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 150.0,
      ),
      FoodModel(
        id: '672000000000000000000005',
        name: 'Malabar Parotta with Paneer Butter Masala',
        category: 'Dinner',
        description:
            'Multi-layered flaky Malabar parottas served with rich, creamy tomato cashewnut gravy and soft cottage cheese cubes.',
        imageUrl:
            'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 220.0,
      ),
      FoodModel(
        id: '672000000000000000000006',
        name: 'Tandoori Butter Naan with Chicken Tikka Masala',
        category: 'Dinner',
        description:
            'Freshly baked clay oven naan topped with melted butter, paired with chargrilled chicken pieces in velvety spiced gravy.',
        imageUrl:
            'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: false,
        price: 290.0,
      ),
      FoodModel(
        id: '672000000000000000000007',
        name: 'Elaneer Payasam (Tender Coconut Kheer)',
        category: 'Sweets',
        description:
            'Signature wedding dessert prepared with chilled fresh coconut milk, cardamom, tender pulp bits, and toasted nuts.',
        imageUrl:
            'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 110.0,
      ),
      FoodModel(
        id: '672000000000000000000008',
        name: 'Ghee Mysore Pak',
        category: 'Sweets',
        description:
            'Melt-in-mouth royal South Indian sweet crafted with pure cow ghee, gram flour, and caramelized sugar.',
        imageUrl:
            'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 90.0,
      ),
      FoodModel(
        id: '672000000000000000000009',
        name: 'Royal Gulab Jamun with Rabdi',
        category: 'Sweets',
        description:
            'Warm golden fried khoya dumplings soaked in saffron-rose syrup, garnished with slow-reduced creamy rabdi and pistachios.',
        imageUrl:
            'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
        isAvailable: true,
        isVegetarian: true,
        price: 120.0,
      ),
    ];

    return catalog.where((item) {
      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'all') {
        if (item.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }
      if (vegetarianOnly == true && !item.isVegetarian) {
        return false;
      }
      if (search != null && search.trim().isNotEmpty) {
        final query = search.toLowerCase();
        final matchName = item.name.toLowerCase().contains(query);
        final matchDesc = item.description.toLowerCase().contains(query);
        final matchCat = item.category.toLowerCase().contains(query);
        if (!matchName && !matchDesc && !matchCat) return false;
      }
      return true;
    }).toList();
  }
}
