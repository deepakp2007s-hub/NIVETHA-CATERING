
import '../models/food_model.dart';
import '../../core/services/food_service.dart';

class FoodRepository {
  FoodRepository({FoodService? foodService})
      : _foodService = foodService ?? FoodService.instance;

  final FoodService _foodService;

  Future<List<FoodModel>> getFoods({
    String? category,
    String? type,
    bool? available,
  }) async {
    final foods = await _foodService.getFoods(
      category: category,
      type: type,
      available: available,
    );

    return foods
        .map(FoodModel.fromJson)
        .where((food) => food.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<FoodModel> getFoodById(String foodId) async {
    final foodJson = await _foodService.getFoodById(foodId);
    return FoodModel.fromJson(foodJson);
  }
}
