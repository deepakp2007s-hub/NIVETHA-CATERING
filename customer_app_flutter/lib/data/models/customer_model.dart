/// Customer model representing an authenticated user profile in Nivetha Catering.
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = 'customer',
    this.createdAt,
  });

  /// Get initials for the avatar badge (e.g., "John Doe" -> "JD")
  String get initials {
    if (name.trim().isEmpty) return 'NC';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // Handle nested customer payload if present
    final Map<String, dynamic> data = json.containsKey('customer') &&
            json['customer'] is Map<String, dynamic>
        ? json['customer']
        : (json.containsKey('profile') && json['profile'] is Map<String, dynamic>
            ? json['profile']
            : (json.containsKey('user') && json['user'] is Map<String, dynamic>
                ? json['user']
                : json));

    DateTime? parsedDate;
    if (data['created_at'] != null) {
      parsedDate = DateTime.tryParse(data['created_at'].toString());
    } else if (data['createdAt'] != null) {
      parsedDate = DateTime.tryParse(data['createdAt'].toString());
    }

    return CustomerModel(
      id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
      name: data['full_name']?.toString() ??
          data['name']?.toString() ??
          'Valued Customer',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'customer',
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': name,
      'email': email,
      'phone': phone,
      'role': role,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
