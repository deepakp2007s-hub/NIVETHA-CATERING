class FoodModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? imageUrl;
  final bool isAvailable;

  FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? json['image'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}