import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/food_model.dart';

class FoodService {
  final Dio _dio = DioClient().dio;

  /// Fetch food menu catalog with optional category and search filters
  Future<List<FoodModel>> getFoods({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.trim().isNotEmpty && category != 'All') {
        queryParams['category'] = category.trim();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await _dio.get(
        ApiConfig.foods,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final List items = response.data is List
            ? response.data
            : (response.data['foods'] ?? []);
        return items.map((json) => FoodModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Failed to load food menu.',
      );
    }
  }

  /// Fetch a single food item by ID
  Future<FoodModel> getFoodById(String foodId) async {
    try {
      final response = await _dio.get('${ApiConfig.foods}/$foodId');
      if (response.statusCode == 200) {
        return FoodModel.fromJson(response.data);
      }
      throw Exception('Food item not found.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Unable to retrieve food details.',
      );
    }
  }
}