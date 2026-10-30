import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  final SecureStorage secureStorage;
  late final Dio _dio;

  ApiClient({required this.secureStorage}) {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await secureStorage.readToken();

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }

            handler.next(options);
          } catch (error) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: error,
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.postUri(
        Uri.parse(ApiConfig.resolve(path)),
        data: data,
      );

      if (response.data is! Map) {
        throw const ApiException(
          message: 'Invalid server response.',
        );
      }

      return Map<String, dynamic>.from(response.data as Map);
    } on ApiConfigurationException {
      rethrow;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final response = await _dio.getUri(
        Uri.parse(ApiConfig.resolve(path)),
      );

      if (response.data is! Map) {
        throw const ApiException(
          message: 'Invalid server response.',
        );
      }

      return Map<String, dynamic>.from(response.data as Map);
    } on ApiConfigurationException {
      rethrow;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}