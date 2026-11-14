import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/customer_model.dart';

/// Service managing customer authentication, token persistence,
/// session storage with SharedPreferences, and logout workflows.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'current_user_data';

  AuthService._internal();

  /// Authenticate customer with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      Response response;
      try {
        // Primary customer login endpoint
        response = await _dio.post(
          ApiConfig.customerLogin,
          data: {
            'email': email.trim().toLowerCase(),
            'password': password,
          },
        );
      } on DioException catch (e) {
        // If 404 on customer endpoint, fallback to unified login endpoint
        if (e.response?.statusCode == 404) {
          response = await _dio.post(
            ApiConfig.login,
            data: {
              'email': email.trim().toLowerCase(),
              'password': password,
            },
          );
        } else {
          rethrow;
        }
      }

      final data = response.data as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['access_token'] != null) {
        final String token = data['access_token'].toString();
        await _saveSession(token: token, userData: data['user']);
      }

      return data;
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Register a new customer account
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final sanitizedPhone = phone.replaceAll(RegExp(r'[\s()+-]'), '');

      Response response;
      try {
        response = await _dio.post(
          ApiConfig.customerRegister,
          data: {
            'full_name': name.trim(),
            'email': email.trim().toLowerCase(),
            'phone': sanitizedPhone,
            'password': password,
          },
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dio.post(
            ApiConfig.register,
            data: {
              'name': name.trim(),
              'email': email.trim().toLowerCase(),
              'phone': sanitizedPhone,
              'password': password,
            },
          );
        } else {
          rethrow;
        }
      }

      final data = response.data as Map<String, dynamic>;

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['access_token'] != null) {
        final String token = data['access_token'].toString();
        await _saveSession(token: token, userData: data['user']);
      }

      return data;
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Store JWT token and customer session payload in SharedPreferences and SecureStorage
  Future<void> _saveSession({
    required String token,
    dynamic userData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);

      if (userData != null) {
        if (userData is Map) {
          await prefs.setString(_userKey, jsonEncode(userData));
        }
      }
    } catch (_) {}

    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (_) {}
  }

  /// Retrieve the authenticated customer profile
  Future<CustomerModel?> getCurrentCustomer() async {
    // Attempt to load from live API
    try {
      final response = await _dio.get(ApiConfig.profile);
      if (response.statusCode == 200) {
        final customer = CustomerModel.fromJson(response.data);
        // Cache to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(customer.toJson()));
        return customer;
      }
    } catch (e) {
      // If 401 Unauthorized, trigger logout
      if (e is DioException && e.response?.statusCode == 401) {
        await logout();
        return null;
      }
    }

    // Fallback to local session storage cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_userKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return CustomerModel.fromJson(jsonDecode(cachedJson));
      }
    } catch (_) {}

    return null;
  }

  /// Retrieve the active JWT token
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}

    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (_) {}

    return null;
  }

  /// Check whether the customer has an active logged-in session
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear session data and revoke local credentials
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}

    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (_) {}
  }
}
