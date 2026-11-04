class BookingModel {
  final String id;
  final String eventType;
  final DateTime eventDate;
  final int guestCount;
  final String venueAddress;
  final String status;
  final List<String> selectedFoodIds;

  BookingModel({
    required this.id,
    required this.eventType,
    required this.eventDate,
    required this.guestCount,
    required this.venueAddress,
    required this.status,
    required this.selectedFoodIds,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] ?? json['id'] ?? '',
      eventType: json['eventType'] ?? '',
      eventDate: DateTime.parse(json['eventDate'] ?? DateTime.now().toIso8601String()),
      guestCount: json['guestCount'] ?? 0,
      venueAddress: json['venueAddress'] ?? '',
      status: json['status'] ?? 'pending',
      selectedFoodIds: List<String>.from(json['selectedFoodIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventType': eventType,
      'eventDate': eventDate.toIso8601String(),
      'guestCount': guestCount,
      'venueAddress': venueAddress,
      'status': status,
      'selectedFoodIds': selectedFoodIds,
    };
  }
}