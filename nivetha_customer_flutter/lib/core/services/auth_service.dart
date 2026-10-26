
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'api_service.dart';
import 'auth_storage_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// Checks whether a saved authentication session exists.
  Future<bool> isLoggedIn() async {
    try {
      final loggedIn = await AuthStorageService.isLoggedIn();
      return loggedIn;
    } catch (error) {
      debugPrint('Unable to restore customer session: $error');
      return false;
    }
  }

  /// Login using the registered mobile number and password.
  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final identifier = emailOrPhone.trim();

    if (identifier.isEmpty || password.isEmpty) {
      throw Exception('Enter your mobile number and password.');
    }

    if (!RegExp(r'^\+?[\d\s\-()]+$').hasMatch(identifier)) {
      throw Exception('Please log in using your mobile number.');
    }

    final phone = _normalizePhone(identifier);

    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
      throw Exception('Enter a valid 10-digit mobile number.');
    }

    try {
      final response = await ApiService.instance.post(
        ApiConfig.loginEndpoint,
        body: {
          'phone': phone,
          'password': password,
        },
        authenticated: false,
      );

      await _saveLoginSession(response);
    } catch (error) {
      debugPrint('Customer login failed: $error');
      rethrow;
    }
  }

  /// Register a customer and save the returned session.
  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String email = '',
    String address = '',
  }) async {
    final cleanName = name.trim();
    final cleanPhone = _normalizePhone(phone);
    final cleanEmail = email.trim().toLowerCase();
    final cleanAddress = address.trim();

    if (cleanName.isEmpty) {
      throw Exception('Enter your full name.');
    }

    if (cleanName.length > 100) {
      throw Exception('Name cannot exceed 100 characters.');
    }

    if (!RegExp(r'^\d{10}$').hasMatch(cleanPhone)) {
      throw Exception('Enter a valid 10-digit mobile number.');
    }

    if (cleanEmail.isNotEmpty &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(cleanEmail)) {
      throw Exception('Enter a valid email address.');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    try {
      final response = await ApiService.instance.post(
        ApiConfig.registerEndpoint,
        body: {
          'name': cleanName,
          'phone': cleanPhone,
          'password': password,
          if (cleanEmail.isNotEmpty) 'email': cleanEmail,
          if (cleanAddress.isNotEmpty) 'address': cleanAddress,
        },
        authenticated: false,
      );

      await _saveLoginSession(response);
    } catch (error) {
      debugPrint('Customer registration failed: $error');
      rethrow;
    }
  }

  String _normalizePhone(String input) {
    var phone = input.replaceAll(RegExp(r'[\s\-()]'), '').trim();

    if (phone.startsWith('+91')) {
      phone = phone.substring(3);
    } else if (phone.startsWith('91') && phone.length == 12) {
      phone = phone.substring(2);
    }

    return phone;
  }

  /// Persist the token and customer details after successful authentication.
  Future<void> _saveLoginSession(dynamic response) async {
    if (response is! Map) {
      throw Exception('Invalid server response. Please try again.');
    }

    final root = Map<String, dynamic>.from(response);

    if (root['success'] == false) {
      final message = _readString([
        root['message'],
        root['error'],
      ]);

      throw Exception(
        message.isNotEmpty
            ? message
            : 'Authentication failed. Please try again.',
      );
    }

    final rawData = root['data'];
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : root;

    final token = _readString([
      data['token'],
      data['accessToken'],
      data['access_token'],
      data['jwt'],
      root['token'],
      root['accessToken'],
      root['access_token'],
      root['jwt'],
    ]);

    if (token.isEmpty) {
      throw Exception(
        'Server response did not contain an authentication token.',
      );
    }

    final rawCustomer =
        data['customer'] ??
        data['user'] ??
        root['customer'] ??
        root['user'];

    final customer = rawCustomer is Map
        ? Map<String, dynamic>.from(rawCustomer)
        : <String, dynamic>{};

    await AuthStorageService.saveSession(
      token: token,
      customerId: _readString([
        customer['_id'],
        customer['id'],
        data['customerId'],
        data['userId'],
      ]),
      customerName: _readString([
        customer['name'],
        customer['fullName'],
        customer['username'],
        data['name'],
      ]),
      customerEmail: _readString([
        customer['email'],
        data['email'],
      ]),
      customerPhone: _readString([
        customer['phone'],
        customer['phoneNumber'],
        customer['mobile'],
        data['phone'],
      ]),
    );

    debugPrint('Customer authentication session saved.');
  }

  String _readString(List<dynamic> values) {
    for (final value in values) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  /// Logout clears the saved session.
  Future<void> logout() async {
    await AuthStorageService.clearSession();
  }

  Future<String?> get savedName =>
      AuthStorageService.getCustomerName();

  Future<String?> get savedEmail =>
      AuthStorageService.getCustomerEmail();

  Future<String?> get savedPhone =>
      AuthStorageService.getCustomerPhone();
}
