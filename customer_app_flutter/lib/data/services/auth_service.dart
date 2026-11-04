import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/customer_model.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['access_token'] != null) {
        final String token = data['access_token'];
        await _storage.write(key: _tokenKey, value: token);
      }
      return data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Login request failed.',
      );
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'phone': phone.trim(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['access_token'] != null) {
        final String token = data['access_token'];
        await _storage.write(key: _tokenKey, value: token);
      }
      return data;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Registration request failed.',
      );
    }
  }

  Future<CustomerModel?> getCurrentCustomer() async {
    try {
      final response = await _dio.get(ApiConfig.profile);
      if (response.statusCode == 200) {
        return CustomerModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await logout();
      }
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Failed to retrieve profile.',
      );
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}
