import 'package:flutter/foundation.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../data/models/food_model.dart';
import '../../../data/repositories/food_repository.dart';

class FoodCatalogProvider extends ChangeNotifier {
  FoodCatalogProvider(this._repository);

  final FoodRepository _repository;

  List<FoodItem> foods = const [];
  bool isLoading = false;
  String? errorMessage;

  List<String> get categories {
    final values = foods
        .map((item) => item.category.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return values;
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      foods = await _repository.getFoods();
    } on ApiException catch (error) {
      errorMessage = error.message;
      foods = const [];
    } catch (_) {
      errorMessage = 'Unable to load the food catalog.';
      foods = const [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<FoodItem> search(String query, {String? category}) {
    final needle = query.trim().toLowerCase();
    return foods.where((item) {
      final matchesCategory = category == null ||
          category == 'All' ||
          item.category.toLowerCase() == category.toLowerCase();
      if (!matchesCategory) return false;
      if (needle.isEmpty) return true;
      return item.name.toLowerCase().contains(needle) ||
          item.description.toLowerCase().contains(needle) ||
          item.category.toLowerCase().contains(needle);
    }).toList();
  }

  List<FoodItem> relatedTo(FoodItem food) {
    return foods
        .where(
          (item) =>
              item.id != food.id &&
              item.category.isNotEmpty &&
              item.category == food.category,
        )
        .take(6)
        .toList();
  }
}
