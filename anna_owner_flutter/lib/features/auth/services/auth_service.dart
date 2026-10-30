import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';

class AuthService {
  final ApiClient apiClient;

  AuthService({required this.apiClient});

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConfig.ownerLogin,
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    if (response['success'] != true) {
      throw const ApiException(
        message: 'Owner login failed.',
      );
    }

    final token = response['access_token'];
    final owner = response['owner'];

    if (token is! String ||
        token.isEmpty ||
        owner is! Map ||
        owner['role'] != 'owner') {
      throw const ApiException(
        message: 'Invalid owner authentication response.',
      );
    }

    return {
      'access_token': token,
      'owner': Map<String, dynamic>.from(owner),
    };
  }
}