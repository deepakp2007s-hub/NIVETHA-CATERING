import '../models/user_model.dart';
import '../models/address_model.dart';
import '../models/notification_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to fetch profile: ${e.toString()}');
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        ApiConfig.profile,
        data: updateData,
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await _dio.get(ApiConfig.addresses);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => AddressModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch addresses: ${e.toString()}');
    }
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final response = await _dio.post(
        ApiConfig.addresses,
        data: address.toJson(),
      );
      return AddressModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to add address: ${e.toString()}');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _dio.delete('${ApiConfig.addresses}/$addressId');
    } catch (e) {
      throw Exception('Failed to delete address: ${e.toString()}');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConfig.notifications);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dio.patch('${ApiConfig.notifications}/$notificationId/read');
    } catch (e) {
      throw Exception('Failed to update notification status: ${e.toString()}');
    }
  }
}