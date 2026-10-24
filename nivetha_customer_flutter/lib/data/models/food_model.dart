
class FoodModel {
  final String id;
  final String name;
  final String tamilName;
  final String category;
  final String type;
  final String description;
  final double price;
  final String image;
  final bool available;

  const FoodModel({
    required this.id,
    required this.name,
    this.tamilName = '',
    this.category = '',
    this.type = '',
    this.description = '',
    this.price = 0,
    this.image = '',
    this.available = true,
  });

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['foodName'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      type: (json['type'] ?? json['foodType'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _parsePrice(json['price'] ?? json['amount']),
      image: (json['image'] ?? json['imageUrl'] ?? '').toString(),
      available: _parseAvailability(json['available']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tamilName': tamilName,
      'category': category,
      'type': type,
      'description': description,
      'price': price,
      'image': image,
      'available': available,
    };
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseAvailability(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text = value.toString().toLowerCase().trim();
    return text != 'false' && text != '0' && text != 'unavailable';
  }

  FoodModel copyWith({
    String? name,
    String? tamilName,
    String? category,
    String? type,
    String? description,
    double? price,
    String? image,
    bool? available,
  }) {
    return FoodModel(
      id: id,
      name: name ?? this.name,
      tamilName: tamilName ?? this.tamilName,
      category: category ?? this.category,
      type: type ?? this.type,
      description: description ?? this.description,
      price: price ?? this.price,
      image: image ?? this.image,
      available: available ?? this.available,
    );
  }
}
