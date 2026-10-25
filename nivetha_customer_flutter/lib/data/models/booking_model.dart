
class BookingModel {
  final String id;
  final String customerId;
  final String bookingId;
  final String eventType;
  final DateTime? eventDate;
  final String eventTime;
  final String location;
  final int numberOfPersons;

  // Backward-compatible fields used by existing booking screens.
  final String cateringType;
  final String mealType;
  final String foodType;

  final List<Map<String, dynamic>> selectedFoods;
  final List<String> cateringServices;
  final String status;
  final double totalAmount;
  final double advanceAmount;
  final String? notes;
  final String? extraRequirements;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    this.customerId = '',
    this.bookingId = '',
    required this.eventType,
    this.eventDate,
    this.eventTime = '',
    this.location = '',
    this.numberOfPersons = 0,
    this.cateringType = '',
    this.mealType = '',
    this.foodType = '',
    this.selectedFoods = const [],
    this.cateringServices = const [],
    this.status = 'pending',
    this.totalAmount = 0,
    this.advanceAmount = 0,
    this.notes,
    this.extraRequirements,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawCustomer = json['customer'] ?? json['customerId'];
    final rawFoods = json['selectedFoods'];
    final rawServices = json['cateringServices'];

    final customerId = rawCustomer is Map
        ? (rawCustomer['_id'] ?? rawCustomer['id'] ?? '').toString()
        : (rawCustomer ?? '').toString();

    final services = rawServices is List
        ? rawServices.map((item) => item.toString()).toList(growable: false)
        : <String>[];

    final foods = rawFoods is List
        ? rawFoods
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false)
        : <Map<String, dynamic>>[];

    return BookingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      customerId: customerId,
      bookingId: (json['bookingId'] ?? '').toString(),
      eventType: (json['eventType'] ??
              json['functionType'] ??
              json['customerType'] ??
              '')
          .toString(),
      eventDate: _parseDate(json['eventDate'] ?? json['functionDate']),
      eventTime: (json['eventTime'] ?? json['functionTime'] ?? '').toString(),
      location: (json['eventLocation'] ?? json['location'] ?? '').toString(),
      numberOfPersons: _toInt(
        json['numberOfPersons'] ?? json['guestCount'] ?? json['persons'],
      ),
      cateringType: _firstString([
        json['cateringType'],
        json['serviceType'],
        ...services,
      ]),
      mealType: _firstString([
        json['mealType'],
        json['meal'],
        json['eventTime'],
      ]),
      foodType: _firstString([
        json['foodType'],
        json['dietType'],
        _deriveFoodType(foods),
      ]),
      selectedFoods: foods,
      cateringServices: services,
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      totalAmount: _toDouble(
        json['totalAmount'] ?? json['totalPayment'] ?? json['totalCost'],
      ),
      advanceAmount: _toDouble(
        json['advanceAmount'] ?? json['advancePayment'],
      ),
      notes: _nullableString(json['notes']),
      extraRequirements: _nullableString(
        json['extraRequirements'] ?? json['notes'],
      ),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  /// Request body for POST /api/bookings.
  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      if (eventDate != null) 'eventDate': _dateOnly(eventDate!),
      'eventTime': eventTime.trim().isEmpty ? 'Morning' : eventTime.trim(),
      'eventLocation': location.trim(),
      'numberOfPersons': numberOfPersons,
      'selectedFoods': selectedFoods,
      'cateringServices': cateringServices,
      if (extraRequirements != null && extraRequirements!.trim().isNotEmpty)
        'extraRequirements': extraRequirements!.trim(),
      if (notes != null && notes!.trim().isNotEmpty)
        'notes': notes!.trim(),
    };
  }

  static String _firstString(List<dynamic> values) {
    for (final value in values) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  static String _deriveFoodType(List<Map<String, dynamic>> foods) {
    final types = foods
        .map((food) => (food['type'] ?? '').toString().trim())
        .where((type) => type.isNotEmpty)
        .toSet();

    if (types.isEmpty) return '';
    if (types.length > 1) return 'Mixed';

    return types.first;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;

    final text = value.toString().trim();
    return text.isEmpty ? null : DateTime.tryParse(text);
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    final text = value?.toString().replaceAll(',', '').trim() ?? '';

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return 0;

    final text = value
        .toString()
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .trim();

    return double.tryParse(text) ?? 0;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  BookingModel copyWith({
    String? status,
    double? totalAmount,
    double? advanceAmount,
    String? notes,
    String? extraRequirements,
    String? cateringType,
    String? mealType,
    String? foodType,
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      bookingId: bookingId,
      eventType: eventType,
      eventDate: eventDate,
      eventTime: eventTime,
      location: location,
      numberOfPersons: numberOfPersons,
      cateringType: cateringType ?? this.cateringType,
      mealType: mealType ?? this.mealType,
      foodType: foodType ?? this.foodType,
      selectedFoods: selectedFoods,
      cateringServices: cateringServices,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      notes: notes ?? this.notes,
      extraRequirements: extraRequirements ?? this.extraRequirements,
      createdAt: createdAt,
    );
  }
}
