
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
    return CustomerModel(
      id: _readString(json['_id'] ?? json['id']),
      name: _readString(json['name'] ?? json['fullName']),
      email: _readString(json['email']),
      phone: _readString(
        json['phone'] ?? json['phoneNumber'] ?? json['mobile'],
      ),
      address: _readNullableString(json['address']),
      profileImage: _readNullableString(
        json['profileImage'] ?? json['avatar'] ?? json['image'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (address != null) 'address': address,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  CustomerModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? profileImage,
    bool clearAddress = false,
    bool clearProfileImage = false,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: clearAddress ? null : address ?? this.address,
      profileImage:
          clearProfileImage ? null : profileImage ?? this.profileImage,
    );
  }

  static String _readString(dynamic value) {
    return value?.toString().trim() ?? '';
  }

  static String? _readNullableString(dynamic value) {
    final result = value?.toString().trim();

    if (result == null || result.isEmpty) {
      return null;
    }

    return result;
  }
}
