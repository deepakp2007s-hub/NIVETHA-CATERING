
class BookingModel {
  final String id;
  final String customerId;
  final String eventType;
  final DateTime? eventDate;
  final String eventTime;
  final String location;
  final int numberOfPersons;
  final String cateringType;
  final String mealType;
  final String foodType;
  final String status;
  final double totalAmount;
  final double advanceAmount;
  final String? notes;
  final DateTime? createdAt;

  const BookingModel({
    required this.id,
    this.customerId = '',
    required this.eventType,
    this.eventDate,
    this.eventTime = '',
    this.location = '',
    this.numberOfPersons = 0,
    this.cateringType = '',
    this.mealType = '',
    this.foodType = '',
    this.status = 'pending',
    this.totalAmount = 0,
    this.advanceAmount = 0,
    this.notes,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['eventDate'] ?? json['functionDate'];
    final rawCreatedAt = json['createdAt'];

    final customerValue = json['customerId'] ?? json['customer'];
    final customerId = customerValue is Map
        ? (customerValue['_id'] ?? customerValue['id'] ?? '').toString()
        : (customerValue ?? '').toString();

    return BookingModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      customerId: customerId,
      eventType: (json['eventType'] ??
              json['functionType'] ??
              json['customerType'] ??
              '')
          .toString(),
      eventDate: _parseDate(rawDate),
      eventTime: (json['eventTime'] ?? json['functionTime'] ?? '').toString(),
      location: (json['location'] ?? json['eventLocation'] ?? '').toString(),
      numberOfPersons: _toInt(
        json['numberOfPersons'] ?? json['persons'] ?? json['guestCount'],
      ),
      cateringType: (json['cateringType'] ?? json['serviceType'] ?? '')
          .toString(),
      mealType: (json['mealType'] ?? json['meal'] ?? '').toString(),
      foodType: (json['foodType'] ?? json['dietType'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString().toLowerCase(),
      totalAmount: _toDouble(
        json['totalAmount'] ?? json['totalPayment'] ?? json['totalCost'],
      ),
      advanceAmount: _toDouble(
        json['advanceAmount'] ?? json['advancePayment'],
      ),
      notes: (json['notes'] ?? json['extraRequirements'])?.toString(),
      createdAt: _parseDate(rawCreatedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      if (eventDate != null) 'eventDate': _dateOnly(eventDate!),
      'eventTime': eventTime,
      'location': location,
      'numberOfPersons': numberOfPersons,
      'cateringType': cateringType,
      'mealType': mealType,
      'foodType': foodType,
      'status': status,
      'totalAmount': totalAmount,
      'advanceAmount': advanceAmount,
      if (notes != null && notes!.trim().isNotEmpty) 'notes': notes,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      eventType: eventType,
      eventDate: eventDate,
      eventTime: eventTime,
      location: location,
      numberOfPersons: numberOfPersons,
      cateringType: cateringType,
      mealType: mealType,
      foodType: foodType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
