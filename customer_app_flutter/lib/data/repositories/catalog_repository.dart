import '../models/category_model.dart';
import '../models/food_item_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class CatalogRepository {
  final Dio _dio;

  CatalogRepository(this._dio);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get(ApiConfig.categories);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: ${e.toString()}');
    }
  }

  Future<List<FoodItemModel>> getFoods({String? categoryId}) async {
    try {
      final response = await _dio.get(
        ApiConfig.foods,
        queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
      );
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => FoodItemModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch food items: ${e.toString()}');
    }
  }

  Future<List<FoodItemModel>> getFavorites() async {
    try {
      final response = await _dio.get(ApiConfig.favorites);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => FoodItemModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorites: ${e.toString()}');
    }
  }

  Future<void> toggleFavorite(String foodId) async {
    try {
      await _dio.post('${ApiConfig.favorites}/$foodId');
    } catch (e) {
      throw Exception('Failed to update favorite: ${e.toString()}');
    }
  }
}