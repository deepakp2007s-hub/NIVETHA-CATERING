
import 'api_service.dart';

class FoodService {
  FoodService._();

  static final FoodService instance = FoodService._();

  final ApiService _api = ApiService.instance;

  // Confirm this route against the deployed backend.
  static const String foodsEndpoint = '/foods/customer';

  Future<List<Map<String, dynamic>>> getFoods() async {
    final response = await _api.get(foodsEndpoint);

    dynamic items = response;

    if (response is Map) {
      items = response['foods'] ??
          response['data'] ??
          response['items'];
    }

    if (items is! List) {
      throw Exception(
        'Invalid food list response received from the server.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) {
          final food = Map<String, dynamic>.from(item);

          // Never expose food prices in the customer app.
          food.remove('price');

          return food;
        })
        .where((food) => food['available'] != false)
        .toList();
  }
}
