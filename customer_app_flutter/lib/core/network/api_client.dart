import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  ApiClient({required this._secureStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.normalizedBaseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 25),
      sendTimeout: const Duration(seconds: 20),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _secureStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        } catch (error) {
          handler.reject(DioException(
            requestOptions: options,
            error: error,
            message: 'Unable to read the secure sign-in session.',
          ));
        }
      },
    ));
  }

  final SecureStorage _secureStorage;
  late final Dio _dio;

  Future<Map<String, dynamic>> get(String path) => _request(() async {
        final response = await _dio.get<Object?>(path);
        return _asMap(response.data);
      });

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) =>
      _request(() async {
        final response = await _dio.post<Object?>(path, data: data);
        return _asMap(response.data);
      });

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> data,
  }) =>
      _request(() async {
        final response = await _dio.patch<Object?>(path, data: data);
        return _asMap(response.data);
      });

  Future<Map<String, dynamic>> delete(String path) => _request(() async {
        final response = await _dio.delete<Object?>(path);
        return _asMap(response.data);
      });

  Future<Map<String, dynamic>> _request(
    Future<Map<String, dynamic>> Function() operation,
  ) async {
    try {
      return await operation();
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const ApiException('The server returned an unexpected response.');
  }
}
