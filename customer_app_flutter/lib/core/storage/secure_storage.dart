import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  // Save JWT Token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Retrieve JWT Token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete JWT Token
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Save User Data (JSON string or encoded data)
  static Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userKey, value: userData);
  }

  // Retrieve User Data
  static Future<String?> getUserData() async {
    return await _storage.read(key: _userKey);
  }

  // Clear All Stored Data (Logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}