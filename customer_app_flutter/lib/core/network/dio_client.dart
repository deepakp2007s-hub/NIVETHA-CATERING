import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Centralized Dio HTTP client configured with request interceptors,
/// bearer token injection from local storage, and structured error formatting.
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Request & Response Interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Read token from SharedPreferences first, fallback to FlutterSecureStorage
          String? token;
          try {
            final prefs = await SharedPreferences.getInstance();
            token = prefs.getString('jwt_token');
          } catch (_) {}

          if (token == null || token.isEmpty) {
            try {
              token = await _secureStorage.read(key: 'jwt_token');
            } catch (_) {}
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Pass formatted error through pipeline
          return handler.next(error);
        },
      ),
    );
  }

  /// Helper to extract clean human-readable error messages from DioExceptions
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is String) return detail;
            if (detail is List && detail.isNotEmpty) {
              final first = detail.first;
              if (first is Map && first.containsKey('msg')) {
                return first['msg'].toString();
              }
              return detail.join(', ');
            }
          }
          if (data.containsKey('message')) {
            return data['message'].toString();
          }
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          if (code == 401) {
            return 'Session expired or invalid credentials. Please log in again.';
          } else if (code == 403) {
            return 'Access denied. You do not have permission for this action.';
          } else if (code == 404) {
            return 'Requested resource not found.';
          } else if (code == 409) {
            return 'Resource conflict or duplicate record found.';
          } else if (code == 422) {
            return 'Please review the entered details and try again.';
          } else if (code != null && code >= 500) {
            return 'Server is temporarily unavailable. Please try again later.';
          }
          return 'Request failed with status code ${code ?? 'unknown'}.';
        case DioExceptionType.connectionError:
          return 'Could not connect to the catering server. Please check your network.';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return error.message ?? 'An unexpected network error occurred.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }
}
