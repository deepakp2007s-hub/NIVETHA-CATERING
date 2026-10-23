
class BookingModel {
  final String id;
  final String customerType;
  final String functionDate;
  final String functionTime;
  final String location;
  final int numberOfPersons;
  final String foodPreference;
  final List<String> meals;
  final String extraRequirements;
  final bool cookingService;
  final bool servingStaff;
  final String status;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    required this.customerType,
    required this.functionDate,
    required this.functionTime,
    required this.location,
    required this.numberOfPersons,
    required this.foodPreference,
    this.meals = const [],
    this.extraRequirements = '',
    this.cookingService = false,
    this.servingStaff = false,
    this.status = 'pending',
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawMeals = json['meals'];

    return BookingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      customerType: (json['customerType'] ?? '').toString(),
      functionDate: (json['functionDate'] ?? '').toString(),
      functionTime: (json['functionTime'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      numberOfPersons: _toInt(json['numberOfPersons']),
      foodPreference: (json['foodPreference'] ?? '').toString(),
      meals: rawMeals is List
          ? rawMeals.map((item) => item.toString()).toList()
          : const [],
      extraRequirements:
          (json['extraRequirements'] ?? '').toString(),
      cookingService: json['cookingService'] == true,
      servingStaff: json['servingStaff'] == true,
      status: (json['status'] ?? 'pending').toString(),
      createdAt: _toDateTime(json['createdAt']),
    );
  }

  factory BookingModel.fromMap(Map<String, dynamic> json) {
    return BookingModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerType': customerType,
      'functionDate': functionDate,
      'functionTime': functionTime,
      'location': location,
      'numberOfPersons': numberOfPersons,
      'foodPreference': foodPreference,
      'meals': meals,
      'extraRequirements': extraRequirements,
      'cookingService': cookingService,
      'servingStaff': servingStaff,
      'status': status,
      if (createdAt != null)
        'createdAt': createdAt!.toIso8601String(),
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  bool get isPending => status.toLowerCase() == 'pending';

  bool get isConfirmed => status.toLowerCase() == 'confirmed';

  bool get isRejected => status.toLowerCase() == 'rejected';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isCompleted => status.toLowerCase() == 'completed';
}
