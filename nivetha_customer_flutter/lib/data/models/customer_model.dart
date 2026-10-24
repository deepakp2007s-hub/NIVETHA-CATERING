
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final String? profileImage;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.profileImage,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'] ?? json['id'];

    return CustomerModel(
      id: idValue?.toString() ?? '',
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? json['mobile'] ?? '').toString(),
      address: json['address']?.toString(),
      profileImage:
          (json['profileImage'] ?? json['avatar'] ?? json['image'])
              ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (address != null) 'address': address,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
