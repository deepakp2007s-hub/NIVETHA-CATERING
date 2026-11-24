import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/food_model.dart';

/// Service managing the catering food catalog, dishes, and categories.
/// Fetches ONLY live food items added by the owner from the backend.
class FoodService {
  static final FoodService _instance = FoodService._internal();
  factory FoodService() => _instance;

  final Dio _dio = DioClient().dio;

  FoodService._internal();

  /// Retrieve the list of food dishes added by the owner with optional filters
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
            : (response.data['foods'] ??
                response.data['items'] ??
                response.data['data'] ??
                []);

        return items
            .whereType()
            .map((json) => FoodModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Retrieve available food categories from backend
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get(ApiConfig.foodCategories);
      if (response.statusCode == 200 && response.data != null) {
        final List raw = response.data is List
            ? response.data
            : (response.data['categories'] ?? []);
        return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Retrieve a specific food dish by its ID
  Future<FoodModel> getFoodById(String foodId) async {
    try {
      final response = await _dio.get(ApiConfig.foodById(foodId));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['food'] ?? response.data)
            : response.data;
        return FoodModel.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Food item not found.');
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }
}