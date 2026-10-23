
import '../models/food_model.dart';
import '../../core/services/food_service.dart';

class FoodRepository {
  FoodRepository._();

  static final FoodRepository instance = FoodRepository._();

  final FoodService _foodService = FoodService.instance;

  Future<List<FoodModel>> getFoods() async {
    final items = await _foodService.getFoods();

    return items
        .map((item) => FoodModel.fromJson(item))
        .toList();
  }

  Future<List<FoodModel>> getAvailableFoods() async {
    final foods = await getFoods();

    return foods
        .where((food) => food.available)
        .toList();
  }

  Future<List<FoodModel>> getFoodsByCategory(
    String category,
  ) async {
    final foods = await getAvailableFoods();

    if (category.trim().isEmpty ||
        category.toLowerCase() == 'all') {
      return foods;
    }

    return foods
        .where(
          (food) =>
              food.category.toLowerCase() ==
              category.trim().toLowerCase(),
        )
        .toList();
  }
}
