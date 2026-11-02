import '../models/food_item_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class FoodRepository {
  final Dio _dio;

  FoodRepository(this._dio);

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

  Future<FoodItemModel> getFoodDetail(String foodId) async {
    try {
      final response = await _dio.get('${ApiConfig.foodDetails}$foodId');
      return FoodItemModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to fetch food detail: ${e.toString()}');
    }
  }
}