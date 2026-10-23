
class CustomerModel {
  final String id;
  final String name;
  final String mobile;
  final String email;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email = '',
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      mobile: (
        json['mobile'] ??
        json['phone'] ??
        json['phoneNumber'] ??
        ''
      ).toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
    );
  }
}
