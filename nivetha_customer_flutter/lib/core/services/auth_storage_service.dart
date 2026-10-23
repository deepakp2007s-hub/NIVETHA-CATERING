
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorageService {
  AuthStorageService._();

  static final AuthStorageService instance =
      AuthStorageService._();

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  static const String _tokenKey = 'customer_auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _customerNameKey = 'customer_name';

  Future<void> saveSession({
    required String token,
    String? customerId,
    String? customerName,
  }) async {
    if (token.trim().isEmpty) {
      throw ArgumentError('Authentication token cannot be empty.');
    }

    await _storage.write(
      key: _tokenKey,
      value: token,
    );

    if (customerId != null) {
      await _storage.write(
        key: _customerIdKey,
        value: customerId,
      );
    }

    if (customerName != null) {
      await _storage.write(
        key: _customerNameKey,
        value: customerName,
      );
    }
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> getCustomerId() async {
    return _storage.read(key: _customerIdKey);
  }

  Future<String?> getCustomerName() async {
    return _storage.read(key: _customerNameKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _customerIdKey);
    await _storage.delete(key: _customerNameKey);
  }
}
