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

        // Update local session cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(customer.toJson()));

        return customer;
      }
      throw Exception('Failed to retrieve customer profile.');
    } catch (e) {
      // Fallback to locally cached customer data
      final cachedCustomer = await AuthService().getCurrentCustomer();
      if (cachedCustomer != null) {
        return cachedCustomer;
      }

      // Default placeholder if newly initialized
      return CustomerModel(
        id: 'cust_local',
        name: 'Valued Customer',
        email: 'customer@nivetha.com',
        phone: '+91 98765 43210',
        role: 'customer',
        createdAt: DateTime.now(),
      );
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

      Response response;
      try {
        // Backend endpoint expects PATCH
        response = await _dio.patch(
          ApiConfig.profile,
          data: updateData,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 405) {
          // Fallback to PUT if PATCH not supported
          response = await _dio.put(
            ApiConfig.profile,
            data: updateData,
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final customer = CustomerModel.fromJson(response.data);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, jsonEncode(customer.toJson()));

        return customer;
      }
      throw Exception('Failed to update profile information.');
    } catch (e) {
      // Offline fallback: update local session cache
      final current = await getProfile();
      final updated = current.copyWith(
        name: (name != null && name.trim().isNotEmpty) ? name.trim() : current.name,
        phone: (phone != null && phone.trim().isNotEmpty) ? phone.trim() : current.phone,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updated.toJson()));

      return updated;
    }
  }
}
