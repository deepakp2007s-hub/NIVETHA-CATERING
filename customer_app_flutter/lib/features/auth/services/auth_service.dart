import '../../../core/network/api_client.dart';

class AuthService {
  AuthService(this._apiClient);
  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      requiresAuth: false,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      requiresAuth: false,
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
      },
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('/customers/me');
    return Map<String, dynamic>.from(response as Map);
  }
}
