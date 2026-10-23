
class FoodModel {
  final String id;
  final String name;
  final String tamilName;
  final String category;
  final String type;
  final String description;
  final String image;
  final bool available;

  const FoodModel({
    required this.id,
    required this.name,
    this.tamilName = '',
    this.category = '',
    this.type = '',
    this.description = '',
    this.image = '',
    this.available = true,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      available: json['available'] == true,
    );
  }

  factory FoodModel.fromMap(Map<String, dynamic> json) {
    return FoodModel.fromJson(json);
  }
}
