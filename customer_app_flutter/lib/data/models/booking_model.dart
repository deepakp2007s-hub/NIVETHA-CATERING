import 'package:flutter/material.dart';

/// Single food item attached to a catering booking.
class SelectedFoodItemModel {
  final String foodId;
  final String foodName;
  final String? category;

  SelectedFoodItemModel({
    required this.foodId,
    required this.foodName,
    this.category,
  });

  factory SelectedFoodItemModel.fromJson(Map<String, dynamic> json) {
    return SelectedFoodItemModel(
      foodId: json['food_id']?.toString() ??
          json['foodId']?.toString() ??
          json['id']?.toString() ??
          '',
      foodName: json['food_name']?.toString() ??
          json['foodName']?.toString() ??
          json['name']?.toString() ??
          '',
      category: json['category']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_id': foodId,
      'food_name': foodName,
      if (category != null) 'category': category,
    };
  }
}

/// Comprehensive model for catering event bookings in Nivetha Catering.
class BookingModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  // Event details
  final String functionType;
  final DateTime eventDate;
  final String eventTime;
  final String location;
  final int personsCount;

  // Catering options
  final bool cateringServiceRequired;
  final bool cookingService;
  final bool servingStaffRequired;
  final String mealType; // Breakfast, Lunch, Dinner, Multiple
  final String foodPreference; // Veg, Non-Veg, Both

  // Selected food items
  final List<SelectedFoodItemModel> selectedFoods;
  final String? specialRequirements;
  final String status; // pending, confirmed, rejected, completed, cancelled
  final String? ownerNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookingModel({
    required this.id,
    this.customerId = '',
    this.customerName = '',
    this.customerEmail = '',
    this.customerPhone = '',
    required this.functionType,
    required this.eventDate,
    this.eventTime = '12:00 PM',
    required this.location,
    required this.personsCount,
    this.cateringServiceRequired = true,
    this.cookingService = true,
    this.servingStaffRequired = false,
    this.mealType = 'Lunch',
    this.foodPreference = 'Veg',
    this.selectedFoods = const [],
    this.specialRequirements,
    this.status = 'pending',
    this.ownerNote,
    this.createdAt,
    this.updatedAt,
    // Optional legacy alias compatibility
    String? eventType,
    int? guestCount,
    String? venueAddress,
    List<String>? selectedFoodIds,
  });

  // ---------------------------------------------------------------------------
  // BACKWARD COMPATIBILITY GETTERS
  // ---------------------------------------------------------------------------
  String get eventType => functionType;
  int get guestCount => personsCount;
  String get venueAddress => location;
  List<String> get selectedFoodIds =>
      selectedFoods.map((f) => f.foodId).toList();

  /// Formatted date string for UI display (e.g., "15 Dec 2026")
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final m = months[eventDate.month - 1];
    return '${eventDate.day.toString().padLeft(2, '0')} $m ${eventDate.year}';
  }

  /// Theme color corresponding to booking status
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E7D32); // Emerald Green
      case 'completed':
        return const Color(0xFF1565C0); // Royal Blue
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFC62828); // Crimson Red
      case 'pending':
      default:
        return const Color(0xFFEF6C00); // Warm Amber
    }
  }

  /// Human-friendly display label for status
  String get formattedStatus {
    if (status.isEmpty) return 'Pending';
    return status[0].toUpperCase() + status.substring(1);
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Parse selected foods array
    final List<SelectedFoodItemModel> foodsList = [];
    if (json['selected_foods'] is List) {
      for (final item in json['selected_foods']) {
        if (item is Map<String, dynamic>) {
          foodsList.add(SelectedFoodItemModel.fromJson(item));
        } else if (item is String) {
          foodsList.add(SelectedFoodItemModel(foodId: item, foodName: 'Dish'));
        }
      }
    } else if (json['selectedFoodIds'] is List) {
      for (final id in json['selectedFoodIds']) {
        foodsList.add(SelectedFoodItemModel(
          foodId: id.toString(),
          foodName: 'Selected Food',
        ));
      }
    }

    // Parse Event Date
    DateTime parsedDate = DateTime.now();
    if (json['event_date'] != null) {
      parsedDate = DateTime.tryParse(json['event_date'].toString()) ?? parsedDate;
    } else if (json['eventDate'] != null) {
      parsedDate = DateTime.tryParse(json['eventDate'].toString()) ?? parsedDate;
    }

    // Parse Timestamps
    DateTime? createdDate;
    if (json['created_at'] != null) {
      createdDate = DateTime.tryParse(json['created_at'].toString());
    }
    DateTime? updatedDate;
    if (json['updated_at'] != null) {
      updatedDate = DateTime.tryParse(json['updated_at'].toString());
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ??
          json['customerId']?.toString() ??
          '',
      customerName: json['customer_name']?.toString() ??
          json['customerName']?.toString() ??
          '',
      customerEmail: json['customer_email']?.toString() ??
          json['customerEmail']?.toString() ??
          '',
      customerPhone: json['customer_phone']?.toString() ??
          json['customerPhone']?.toString() ??
          '',
      functionType: json['function_type']?.toString() ??
          json['eventType']?.toString() ??
          'Event Catering',
      eventDate: parsedDate,
      eventTime: json['event_time']?.toString() ??
          json['eventTime']?.toString() ??
          '12:00 PM',
      location: json['location']?.toString() ??
          json['venueAddress']?.toString() ??
          '',
      personsCount: (json['persons_count'] ?? json['guestCount'] ?? 100) as int,
      cateringServiceRequired: json['catering_service_required'] ?? true,
      cookingService: json['cooking_service'] ?? true,
      servingStaffRequired: json['serving_staff_required'] ?? false,
      mealType: json['meal_type']?.toString() ?? 'Lunch',
      foodPreference: json['food_preference']?.toString() ?? 'Veg',
      selectedFoods: foodsList,
      specialRequirements: json['special_requirements']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      ownerNote: json['owner_note']?.toString(),
      createdAt: createdDate,
      updatedAt: updatedDate,
    );
  }

  Map<String, dynamic> toJson() {
    final dateIso =
        '${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';

    return {
      'function_type': functionType,
      'eventType': functionType,
      'event_date': dateIso,
      'eventDate': eventDate.toIso8601String(),
      'event_time': eventTime,
      'location': location,
      'venueAddress': location,
      'persons_count': personsCount,
      'guestCount': personsCount,
      'catering_service_required': cateringServiceRequired,
      'cooking_service': cookingService,
      'serving_staff_required': servingStaffRequired,
      'meal_type': mealType,
      'food_preference': foodPreference,
      'selected_foods': selectedFoods.map((f) => f.toJson()).toList(),
      'selectedFoodIds': selectedFoods.map((f) => f.foodId).toList(),
      if (specialRequirements != null && specialRequirements!.trim().isNotEmpty)
        'special_requirements': specialRequirements!.trim(),
      'status': status,
    };
  }
}
