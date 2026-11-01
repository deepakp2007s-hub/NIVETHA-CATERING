import '../../../core/network/api_client.dart';

class AuthService {
  AuthService(this._apiClient);
  final ApiClient _apiClient;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _apiClient.post('/auth/login', data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      });

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      _apiClient.post('/auth/register', data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
      });

  Future<Map<String, dynamic>> getProfile() => _apiClient.get('/customers/me');
}
