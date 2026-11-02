class FoodItemModel {
  final String id;
  final String name;
  final String categoryId;
  final String imageUrl;
  final String description;
  final bool isVeg;
  final bool isAvailable;

  const FoodItemModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.imageUrl,
    required this.description,
    required this.isVeg,
    required this.isAvailable,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      isVeg: json['isVeg'] ?? true,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'description': description,
      'isVeg': isVeg,
      'isAvailable': isAvailable,
    };
  }
}