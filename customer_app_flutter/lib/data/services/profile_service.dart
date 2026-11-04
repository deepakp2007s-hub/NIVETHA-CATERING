import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/customer_model.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;

  /// Fetch currently authenticated customer profile
  Future<CustomerModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);

      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['customer'] ?? response.data)
            : response.data;
        return CustomerModel.fromJson(data);
      }
      throw Exception('Failed to retrieve customer profile.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Unable to fetch profile details.',
      );
    }
  }

  /// Update customer profile details (Name, Phone)
  Future<CustomerModel> updateProfile({
    String? name,
    String? phone,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        updateData['phone'] = phone.trim();
      }

      final response = await _dio.put(
        ApiConfig.profile,
        data: updateData,
      );

      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['customer'] ?? response.data)
            : response.data;
        return CustomerModel.fromJson(data);
      }
      throw Exception('Failed to update profile information.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Unable to process profile update.',
      );
    }
  }
}