

import '../../data/models/customer_model.dart';

import 'api_service.dart';

class CustomerService {
  CustomerService._();

  static final CustomerService instance = CustomerService._();

  static const String _profileEndpoint = '/customer-auth/profile';

  final ApiService _api = ApiService.instance;

  Future<CustomerModel> getProfile() async {
    final response = await _api.get(
      _profileEndpoint,
      authenticated: true,
    );

    return CustomerModel.fromJson(_extractCustomer(response));
  }

  Future<CustomerModel> updateProfile({
    required String name,
    String? email,
    String? address,
  }) async {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw ArgumentError('Name cannot be empty.');
    }

    if (cleanName.length > 100) {
      throw ArgumentError('Name cannot exceed 100 characters.');
    }

    final cleanEmail = email?.trim();
    final cleanAddress = address?.trim();

    if (cleanEmail != null && cleanEmail.isNotEmpty) {
      final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

      if (!emailPattern.hasMatch(cleanEmail)) {
        throw ArgumentError('Enter a valid email address.');
      }
    }

    final body = <String, dynamic>{
      'name': cleanName,
      if (cleanEmail != null) 'email': cleanEmail,
      if (cleanAddress != null) 'address': cleanAddress,
    };

    final response = await _api.put(
      _profileEndpoint,
      body: body,
      authenticated: true,
    );

    return CustomerModel.fromJson(_extractCustomer(response));
  }

  Map<String, dynamic> _extractCustomer(dynamic response) {
    if (response is! Map) {
      throw const FormatException(
        'Invalid customer profile response.',
      );
    }

    final root = Map<String, dynamic>.from(response);

    if (root['success'] == false) {
      throw ApiException(
        root['message']?.toString() ?? 'Failed to load customer profile.',
      );
    }

    final customer = root['customer'];

    if (customer is Map) {
      return Map<String, dynamic>.from(customer);
    }

    final data = root['data'];

    if (data is Map) {
      final nested = Map<String, dynamic>.from(data);
      final nestedCustomer = nested['customer'];

      if (nestedCustomer is Map) {
        return Map<String, dynamic>.from(nestedCustomer);
      }

      if (nested.containsKey('_id') || nested.containsKey('id')) {
        return nested;
      }
    }

    if (root.containsKey('_id') || root.containsKey('id')) {
      return root;
    }

    throw const FormatException(
      'Customer details were not found in the response.',
    );
  }
}
