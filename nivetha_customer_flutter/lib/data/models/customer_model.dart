
class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final DateTime? createdAt;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.createdAt,
  });

  String get mobile => phone;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? json['mobile'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']),
    );
  }

  factory CustomerModel.fromMap(Map<String, dynamic> json) {
    return CustomerModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      if (createdAt != null)
        'createdAt': createdAt!.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
