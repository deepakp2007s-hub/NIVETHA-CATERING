import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/customer_model.dart';
import 'auth_service.dart';

/// Service managing customer profile details, retrieval, and profile updates.
class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;

  final Dio _dio = DioClient().dio;
  static const String _userKey = 'current_user_data';

  ProfileService._internal();

  /// Retrieve the current customer's profile
  Future<CustomerModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);

      if (response.statusCode == 200 && response.data != null) {
        final customer = CustomerModel.fromJson(response.data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(customer.toJson()));

        return customer;
      }
      throw Exception('Failed to retrieve customer profile.');
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        await AuthService().logout();
        throw Exception(DioClient.getErrorMessage(e));
      }

      // Fallback to locally cached customer data only when offline
      final cachedCustomer = await AuthService().getCurrentCustomer();
      if (cachedCustomer != null) {
        return cachedCustomer;
      }

      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Update customer profile information (Name, Phone number)
  Future<CustomerModel> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null && name.trim().isNotEmpty) {
        updateData['full_name'] = name.trim();
        updateData['name'] = name.trim();
      }

      if (phone != null && phone.trim().isNotEmpty) {
        final sanitizedPhone = phone.replaceAll(RegExp(r'[\s()+-]'), '');
        updateData['phone'] = sanitizedPhone;
      }

      if (updateData.isEmpty) {
        throw Exception('Please enter at least one field to update.');
      }

      final response = await _dio.patch(
        ApiConfig.profile,
        data: updateData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final customer = CustomerModel.fromJson(response.data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(customer.toJson()));

        return customer;
      }
      throw Exception('Failed to update profile information.');
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }
}