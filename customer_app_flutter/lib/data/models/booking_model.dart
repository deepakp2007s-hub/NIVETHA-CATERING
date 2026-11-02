class BookingModel {
  final String id;
  final String eventType;
  final String eventDate;
  final String eventTime;
  final String guestCount;
  final String venueAddress;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final List<String> selectedFoodIds;
  final String? specialNotes;

  const BookingModel({
    required this.id,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.guestCount,
    required this.venueAddress,
    required this.status,
    required this.selectedFoodIds,
    this.specialNotes,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventType: json['eventType'] ?? '',
      eventDate: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '',
      guestCount: json['guestCount']?.toString() ?? '0',
      venueAddress: json['venueAddress'] ?? '',
      status: json['status'] ?? 'pending',
      selectedFoodIds: List<String>.from(json['selectedFoodIds'] ?? []),
      specialNotes: json['specialNotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'guestCount': guestCount,
      'venueAddress': venueAddress,
      'status': status,
      'selectedFoodIds': selectedFoodIds,
      'specialNotes': specialNotes,
    };
  }
}