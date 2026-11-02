import '../models/user_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  Future<UserModel> register(String name, String email, String phone, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        },
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiConfig.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to verify OTP: ${e.toString()}');
    }
  }
}