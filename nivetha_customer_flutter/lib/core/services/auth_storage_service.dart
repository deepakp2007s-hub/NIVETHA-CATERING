
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorageService {
  AuthStorageService._();

  static const String _tokenKey = 'auth_token';
  static const String _customerIdKey = 'customer_id';
  static const String _customerNameKey = 'customer_name';
  static const String _customerEmailKey = 'customer_email';
  static const String _customerPhoneKey = 'customer_phone';

  /// Save authentication token and customer details locally.
  static Future<void> saveSession({
    required String token,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
  }) async {
    final cleanToken = token.trim();

    if (cleanToken.isEmpty) {
      throw ArgumentError(
        'Authentication token cannot be empty.',
      );
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_tokenKey, cleanToken);

    await _saveOptional(
      prefs,
      _customerIdKey,
      customerId,
    );

    await _saveOptional(
      prefs,
      _customerNameKey,
      customerName,
    );

    await _saveOptional(
      prefs,
      _customerEmailKey,
      customerEmail,
    );

    await _saveOptional(
      prefs,
      _customerPhoneKey,
      customerPhone,
    );
  }

  static Future<void> _saveOptional(
    SharedPreferences prefs,
    String key,
    String? value,
  ) async {
    final cleanValue = value?.trim() ?? '';

    if (cleanValue.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, cleanValue);
    }
  }

  /// Return the saved authentication token.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return token.trim();
  }

  /// Return the saved customer ID.
  static Future<String?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerIdKey);
  }

  /// Return the saved customer name.
  static Future<String?> getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerNameKey);
  }

  /// Return the saved customer email.
  static Future<String?> getCustomerEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerEmailKey);
  }

  /// Return the saved customer phone.
  static Future<String?> getCustomerPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_customerPhoneKey);
  }

  /// Check whether a token is saved locally.
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  /// Clear all saved authentication and customer data.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_tokenKey),
      prefs.remove(_customerIdKey),
      prefs.remove(_customerNameKey),
      prefs.remove(_customerEmailKey),
      prefs.remove(_customerPhoneKey),
    ]);
  }
}
