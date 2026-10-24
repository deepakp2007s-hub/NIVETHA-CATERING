
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  AuthStorageService._();

  static const String _tokenKey = 'auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _customerNameKey = 'customer_name';
  static const String _customerEmailKey = 'customer_email';
  static const String _customerPhoneKey = 'customer_phone';

  // Save login session
  static Future<void> saveSession({
    required String token,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, token);

    await _saveOptional(
      prefs: prefs,
      key: _customerIdKey,
      value: customerId,
    );

    await _saveOptional(
      prefs: prefs,
      key: _customerNameKey,
      value: customerName,
    );

    await _saveOptional(
      prefs: prefs,
      key: _customerEmailKey,
      value: customerEmail,
    );

    await _saveOptional(
      prefs: prefs,
      key: _customerPhoneKey,
      value: customerPhone,
    );
  }

  // Save or remove optional customer details
  static Future<void> _saveOptional({
    required SharedPreferences prefs,
    required String key,
    required String? value,
  }) async {
    final String cleanedValue = value?.trim() ?? '';

    if (cleanedValue.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, cleanedValue);
    }
  }

  // Get authentication token
  static Future<String?> getToken() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // Get customer ID
  static Future<String?> getCustomerId() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_customerIdKey);
  }

  // Get customer name
  static Future<String?> getCustomerName() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_customerNameKey);
  }

  // Get customer email
  static Future<String?> getCustomerEmail() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_customerEmailKey);
  }

  // Get customer phone
  static Future<String?> getCustomerPhone() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_customerPhoneKey);
  }

  // Check login status
  static Future<bool> isLoggedIn() async {
    final String? token = await getToken();

    return token != null && token.trim().isNotEmpty;
  }

  // Clear session during logout
  static Future<void> clearSession() async {
    final SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_customerIdKey);
    await prefs.remove(_customerNameKey);
    await prefs.remove(_customerEmailKey);
    await prefs.remove(_customerPhoneKey);
  }
}
