
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'anna_owner_access_token';
  static const String _emailKey = 'anna_owner_email';

  Future<void> saveSession({
    required String token,
    required String email,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _emailKey, value: email);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> readEmail() async {
    return _storage.read(key: _emailKey);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
  }
}
