class EventModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int defaultGuestCount;

  const EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.defaultGuestCount,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      defaultGuestCount: json['defaultGuestCount'] ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'defaultGuestCount': defaultGuestCount,
    };
  }
}