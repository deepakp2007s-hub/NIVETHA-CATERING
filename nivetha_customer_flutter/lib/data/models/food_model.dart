
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
    final rawAvailability = json['isAvailable'] ??
        json['available'] ??
        json['availability'];

    return FoodModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['foodName'] ?? '').toString(),
      tamilName: (json['tamilName'] ?? '').toString(),
      category: (json['category'] ?? json['mealType'] ?? '').toString(),
      type: (json['type'] ?? json['foodType'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _parsePrice(json['price'] ?? json['amount']),
      image: (json['imageUrl'] ??
              json['image'] ??
              json['photo'] ??
              '')
          .toString(),
      available: _parseAvailability(
        rawAvailability,
        status: json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'tamilName': tamilName,
      'category': category,
      'type': type,
      'description': description,
      'price': price,
      'imageUrl': image,
      'isAvailable': available,
    };
  }

  static double _parsePrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value == null) return 0;

    final normalized = value
        .toString()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .trim();

    return double.tryParse(normalized) ?? 0;
  }

  static bool _parseAvailability(
    dynamic value, {
    dynamic status,
  }) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    if (value != null) {
      final text = value.toString().trim().toLowerCase();

      if (const {
        'false',
        '0',
        'unavailable',
        'inactive',
        'disabled',
        'out of stock',
      }.contains(text)) {
        return false;
      }

      if (const {
        'true',
        '1',
        'available',
        'active',
        'enabled',
        'in stock',
      }.contains(text)) {
        return true;
      }
    }

    if (status != null) {
      final normalizedStatus = status.toString().trim().toLowerCase();

      if (const {
        'inactive',
        'unavailable',
        'disabled',
        'out of stock',
      }.contains(normalizedStatus)) {
        return false;
      }

      if (const {
        'active',
        'available',
        'enabled',
        'in stock',
      }.contains(normalizedStatus)) {
        return true;
      }
    }

    return true;
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
