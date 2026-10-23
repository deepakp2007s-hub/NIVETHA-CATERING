
import 'api_service.dart';

class FoodService {
  FoodService._();

  static final FoodService instance = FoodService._();

  final ApiService _api = ApiService.instance;

  static const String foodsEndpoint = '/foods/customer';

  Future<List<Map<String, dynamic>>> getFoods() async {
    final response = await _api.get(foodsEndpoint);

    dynamic items = response;

    if (response is Map) {
      items = response['data'] ??
          response['foods'] ??
          response['items'];
    }

    if (items is! List) {
      throw Exception(
        'Invalid food list response received from the server.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((food) => food['available'] != false)
        .map((food) {
          // Customer app must not display food prices.
          food.remove('price');
          return food;
        })
        .toList();
  }
}
