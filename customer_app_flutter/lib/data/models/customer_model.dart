class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}