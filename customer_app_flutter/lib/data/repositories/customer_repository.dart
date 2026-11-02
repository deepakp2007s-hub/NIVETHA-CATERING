import '../models/user_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class CustomerRepository {
  final Dio _dio;

  CustomerRepository(this._dio);

  Future<UserModel> getCustomerProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to fetch customer profile: ${e.toString()}');
    }
  }

  Future<UserModel> updateCustomerProfile(Map<String, dynamic> updateData) async {
    try {
      final response = await _dio.put(
        ApiConfig.profile,
        data: updateData,
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to update customer profile: ${e.toString()}');
    }
  }
}