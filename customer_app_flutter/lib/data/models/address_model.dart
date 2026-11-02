class AddressModel {
  final String id;
  final String title;
  final String addressLine;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.title,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      addressLine: json['addressLine'] ?? json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? json['postalCode'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}