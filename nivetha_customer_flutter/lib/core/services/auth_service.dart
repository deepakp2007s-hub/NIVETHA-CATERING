
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import 'api_service.dart';
import 'auth_storage_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<bool> isLoggedIn() async {
    return AuthStorageService.isLoggedIn();
  }

  Future<void> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final identifier = emailOrPhone.trim();

    if (identifier.isEmpty || password.isEmpty) {
      throw Exception('Enter your email/mobile number and password.');
    }

    try {
      final response = await ApiService.instance.post(
        ApiConfig.loginEndpoint,
        body: {
          'emailOrPhone': identifier,
          'password': password,
        },
        authenticated: false,
      );

      await _saveLoginSession(response);
    } catch (error) {
      debugPrint('Login error: $error');
      rethrow;
    }
  }

  Future<void> _saveLoginSession(dynamic response) async {
    if (response is! Map) {
      throw Exception('Invalid server response. Please try again.');
    }

    final root = Map<String, dynamic>.from(response);

    final nestedData = root['data'];
    final data = nestedData is Map
        ? Map<String, dynamic>.from(nestedData)
        : root;

    final token = _readString([
      data['token'],
      data['accessToken'],
      data['access_token'],
      root['token'],
      root['accessToken'],
    ]);

    if (token.isEmpty) {
      throw Exception(
        'Login response did not contain an authentication token.',
      );
    }

    final rawCustomer =
        data['customer'] ?? data['user'] ?? root['customer'] ?? root['user'];

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
        data['name'],
      ]),
      customerEmail: _readString([
        customer['email'],
        data['email'],
      ]),
      customerPhone: _readString([
        customer['phone'],
        customer['mobile'],
        data['phone'],
      ]),
    );
  }

  String _readString(List<dynamic> values) {
    for (final value in values) {
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return '';
  }

  Future<void> logout() async {
    await AuthStorageService.clearSession();
  }

  Future<String?> get savedName async {
    return AuthStorageService.getCustomerName();
  }

  Future<String?> get savedEmail async {
    return AuthStorageService.getCustomerEmail();
  }

  Future<String?> get savedPhone async {
    return AuthStorageService.getCustomerPhone();
  }
}
