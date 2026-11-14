/// Model representing a food or delicacy item offered by Nivetha Catering.
class FoodModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String? imageUrl;
  final bool isAvailable;
  final bool isVegetarian;
  final double price;

  FoodModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.imageUrl,
    this.isAvailable = true,
    this.isVegetarian = true,
    this.price = 0.0,
  });

  /// Category badge display helper
  String get formattedCategory {
    if (category.isEmpty) return 'General';
    return category[0].toUpperCase() + category.substring(1);
  }

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    // Determine image URL from common backend field variants
    final String? img = json['image_url']?.toString() ??
        json['imageUrl']?.toString() ??
        json['image']?.toString();

    // Determine vegetarian status
    bool isVeg = true;
    if (json.containsKey('is_vegetarian')) {
      isVeg = json['is_vegetarian'] == true ||
          json['is_vegetarian'].toString() == 'true';
    } else if (json.containsKey('isVegetarian')) {
      isVeg = json['isVegetarian'] == true ||
          json['isVegetarian'].toString() == 'true';
    } else if (json.containsKey('is_veg')) {
      isVeg = json['is_veg'] == true || json['is_veg'].toString() == 'true';
    }

    // Determine availability
    bool available = true;
    if (json.containsKey('is_available')) {
      available = json['is_available'] == true ||
          json['is_available'].toString() == 'true';
    } else if (json.containsKey('isAvailable')) {
      available = json['isAvailable'] == true ||
          json['isAvailable'].toString() == 'true';
    }

    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    return FoodModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Delicious Dish',
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      imageUrl: (img != null && img.trim().isNotEmpty) ? img.trim() : null,
      isAvailable: available,
      isVegetarian: isVeg,
      price: parsedPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'imageUrl': imageUrl,
      'is_available': isAvailable,
      'isAvailable': isAvailable,
      'is_vegetarian': isVegetarian,
      'isVegetarian': isVegetarian,
      'price': price,
    };
  }

  FoodModel copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? imageUrl,
    bool? isAvailable,
    bool? isVegetarian,
    double? price,
  }) {
    return FoodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      price: price ?? this.price,
    );
  }
}
