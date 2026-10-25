
import '../config/api_config.dart';
import 'api_service.dart';

class FoodService {
  FoodService._();

  static final FoodService instance = FoodService._();

  final ApiService _api = ApiService.instance;

  /// Fetch food items with optional category, type and availability filters.
  Future<List<Map<String, dynamic>>> getFoods({
    String? category,
    String? type,
    String? search,
    bool? available,
  }) async {
    final query = <String, String>{};

    final cleanCategory = category?.trim();
    final cleanType = type?.trim();
    final cleanSearch = search?.trim();

    if (cleanCategory != null &&
        cleanCategory.isNotEmpty &&
        cleanCategory.toLowerCase() != 'all') {
      query['category'] = cleanCategory;
    }

    if (cleanType != null &&
        cleanType.isNotEmpty &&
        cleanType.toLowerCase() != 'all') {
      query['type'] = cleanType;
    }

    if (cleanSearch != null && cleanSearch.isNotEmpty) {
      query['search'] = cleanSearch;
    }

    if (available != null) {
      query['available'] = available.toString();
    }

    final response = await _api.get(
      ApiConfig.foodsEndpoint,
      queryParameters: query.isEmpty ? null : query,
    );

    return _extractFoods(
      response,
      requestedAvailability: available,
    );
  }

  /// Fetch one food item by MongoDB ID.
  Future<Map<String, dynamic>> getFoodById(String foodId) async {
    final id = foodId.trim();

    if (id.isEmpty) {
      throw const ApiException('Food ID is required.');
    }

    final response = await _api.get(
      '${ApiConfig.foodsEndpoint}/${Uri.encodeComponent(id)}',
    );

    return _extractFood(response);
  }

  List<Map<String, dynamic>> _extractFoods(
    dynamic response, {
    bool? requestedAvailability,
  }) {
    dynamic items = response;

    if (response is Map) {
      final root = Map<String, dynamic>.from(response);

      if (root['success'] == false) {
        throw ApiException(
          root['message']?.toString() ?? 'Failed to load food items.',
        );
      }

      items = root['data'] ??
          root['foods'] ??
          root['results'] ??
          root['items'];

      if (items is Map) {
        final nested = Map<String, dynamic>.from(items);

        items = nested['foods'] ??
            nested['results'] ??
            nested['items'];
      }
    }

    if (items is! List) {
      throw const ApiException(
        'Food server returned an unexpected response.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((food) {
          if (requestedAvailability == null) return true;

          final isAvailable = _parseAvailability(food);
          return isAvailable == requestedAvailability;
        })
        .toList(growable: false);
  }

  Map<String, dynamic> _extractFood(dynamic response) {
    if (response is Map) {
      final root = Map<String, dynamic>.from(response);

      if (root['success'] == false) {
        throw ApiException(
          root['message']?.toString() ?? 'Failed to load food details.',
        );
      }

      dynamic data = root['data'] ?? root['food'] ?? root;

      if (data is Map) {
        final food = Map<String, dynamic>.from(data);

        if (food['food'] is Map) {
          return Map<String, dynamic>.from(food['food'] as Map);
        }

        return food;
      }
    }

    throw const ApiException(
      'Food details could not be loaded.',
    );
  }

  bool _parseAvailability(Map<String, dynamic> food) {
    final value = food['isAvailable'] ??
        food['available'] ??
        food['availability'] ??
        food['status'];

    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value.toString().trim().toLowerCase();

    if (const {
      'false',
      '0',
      'unavailable',
      'inactive',
      'disabled',
      'out of stock',
    }.contains(normalized)) {
      return false;
    }

    if (const {
      'true',
      '1',
      'available',
      'active',
      'enabled',
      'in stock',
    }.contains(normalized)) {
      return true;
    }

    return true;
  }
}
