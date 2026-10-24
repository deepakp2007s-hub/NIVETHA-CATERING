
import '../config/api_config.dart';
import 'api_service.dart';

class FoodService {
  FoodService._();

  static final FoodService instance = FoodService._();

  final ApiService _api = ApiService.instance;

  Future<List<Map<String, dynamic>>> getFoods({
    String? category,
    String? type,
    bool? available,
  }) async {
    final query = <String, String>{};

    if (category != null && category.trim().isNotEmpty) {
      query['category'] = category.trim();
    }

    if (type != null && type.trim().isNotEmpty) {
      query['type'] = type.trim();
    }

    if (available != null) {
      query['available'] = available.toString();
    }

    final response = await _api.get(
      ApiConfig.foodsEndpoint,
      queryParameters: query.isEmpty ? null : query,
    );

    return _extractFoods(response);
  }

  Future<Map<String, dynamic>> getFoodById(String foodId) async {
    if (foodId.trim().isEmpty) {
      throw const ApiException('Food ID is required.');
    }

    final response = await _api.get(
      '${ApiConfig.foodsEndpoint}/${Uri.encodeComponent(foodId)}',
    );

    return _asMap(response);
  }

  List<Map<String, dynamic>> _extractFoods(dynamic response) {
    dynamic items = response;

    if (response is Map) {
      items = response['foods'] ??
          response['data'] ??
          response['results'] ??
          response['items'];
    }

    if (items is! List) {
      throw const ApiException(
        'Food server returned an unexpected response.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((food) => food['available'] != false)
        .toList(growable: false);
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map) {
      final data = response['food'] ?? response['data'] ?? response;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }

    throw const ApiException(
      'Food details could not be loaded.',
    );
  }
}
