import '../../core/storage/secure_storage.dart';
import '../../data/models/customer_model.dart';
import '../../features/auth/services/auth_service.dart';

class AuthRepository {
  AuthRepository({required this._service, required this._storage});

  final AuthService _service;
  final SecureStorage _storage;

  Future<bool> hasToken() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<Customer> login(String email, String password) =>
      _authenticate(() => _service.login(email: email, password: password));

  Future<Customer> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) =>
      _authenticate(() => _service.register(
            name: name,
            email: email,
            phone: phone,
            password: password,
          ));

  Future<Customer> loadProfile() async {
    final response = await _service.getProfile();
    final value = response['customer'];
    if (value is! Map) throw Exception('Customer profile is missing.');
    return Customer.fromJson(Map<String, dynamic>.from(value));
  }

  Future<void> logout() => _storage.clearToken();

  Future<Customer> _authenticate(
    Future<Map<String, dynamic>> Function() request,
  ) async {
    final response = await request();
    final token = response['access_token'];
    final customer = response['customer'];
    if (token is! String || token.isEmpty || customer is! Map) {
      throw Exception('The authentication response was incomplete.');
    }
    await _storage.saveToken(token);
    return Customer.fromJson(Map<String, dynamic>.from(customer));
  }
}
