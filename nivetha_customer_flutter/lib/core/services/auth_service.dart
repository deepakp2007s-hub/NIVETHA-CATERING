
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final ApiService _api = ApiService.instance;

  // Confirm these routes against your deployed backend before using.
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';

  Future<Map<String, dynamic>> login({
    required String mobile,
    required String password,
  }) async {
    final response = await _api.post(
      loginEndpoint,
      body: {
        'mobile': mobile.trim(),
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
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'mobile': mobile.trim(),
      'password': password,
    };

    final cleanedEmail = email?.trim() ?? '';

    if (cleanedEmail.isNotEmpty) {
      body['email'] = cleanedEmail;
    }

    final response = await _api.post(
      registerEndpoint,
      body: body,
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

    throw Exception('Invalid response received from the server.');
  }
}
