
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiService _api = ApiService.instance;

  static const String loginEndpoint = '/customer-auth/login';
  static const String registerEndpoint = '/customer-auth/register';
  static const String profileEndpoint = '/customer-auth/me';

  Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    final response = await _api.post(
      loginEndpoint,
      body: {
        'phone': mobile.trim(),
        'password': password,
      },
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String mobile,
    String? email,
    required String password,
    String? address,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'phone': mobile.trim(),
      'password': password,
    };

    final cleanedEmail = email?.trim() ?? '';
    final cleanedAddress = address?.trim() ?? '';

    if (cleanedEmail.isNotEmpty) {
      body['email'] = cleanedEmail;
    }

    if (cleanedAddress.isNotEmpty) {
      body['address'] = cleanedAddress;
    }

    final response = await _api.post(
      registerEndpoint,
      body: body,
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> getProfile({
    required String token,
  }) async {
    final response = await _api.get(
      profileEndpoint,
      token: token,
    );

    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception(
      'Invalid response received from the server.',
    );
  }
}
