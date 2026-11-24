import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
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
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: kIsWeb ? null : const Duration(seconds: 60),
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
          debugPrint(
            '[DioError] ${error.requestOptions.method} '
            '${error.requestOptions.uri} -> ${error.type}: ${error.message}',
          );
          return handler.next(error);
        },
      ),
    );
  }

  /// Helper to extract clean human-readable error messages from DioExceptions,
  /// preserving backend validation details and HTTP status context.
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      debugPrint(
        '[DioClient Error] ${error.requestOptions.method} ${error.requestOptions.path} '
        'Status: $statusCode, Type: ${error.type}, Data: ${error.response?.data}',
      );

      // 1. Extract backend-provided detail or validation messages
      if (error.response?.data != null) {
        final data = error.response!.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            final detail = data['detail'];
            if (detail is String && detail.trim().isNotEmpty) {
              return statusCode != null
                  ? '$detail (HTTP $statusCode)'
                  : detail;
            }
            if (detail is List && detail.isNotEmpty) {
              final messages = <String>[];
              for (final item in detail) {
                if (item is Map) {
                  final loc = item['loc'];
                  final field = (loc is List && loc.isNotEmpty)
                      ? loc.where((part) => part != 'body').join('.')
                      : '';
                  final msg = item['msg']?.toString() ?? 'Invalid value';
                  messages.add(field.isNotEmpty ? '$field: $msg' : msg);
                } else {
                  messages.add(item.toString());
                }
              }
              final joined = messages.join('\n');
              return statusCode != null
                  ? '$joined (HTTP $statusCode)'
                  : joined;
            }
          }
          if (data.containsKey('message')) {
            final message = data['message'].toString();
            return statusCode != null
                ? '$message (HTTP $statusCode)'
                : message;
          }
        } else if (data is String && data.trim().isNotEmpty) {
          final cleanStr = data.trim();
          if (!cleanStr.startsWith('<')) {
            return statusCode != null
                ? '$cleanStr (HTTP $statusCode)'
                : cleanStr;
          }
        }
      }

      // 2. Fallbacks based on DioExceptionType & HTTP Status Codes
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timed out. Server took too long to respond. [Timeout]';
        case DioExceptionType.badResponse:
          final code = statusCode;
          if (code == 401) {
            return 'Invalid credentials or session expired. Please log in again (HTTP 401).';
          } else if (code == 403) {
            return 'Access denied. You do not have permission for this action (HTTP 403).';
          } else if (code == 404) {
            return 'Requested resource not found on server (HTTP 404).';
          } else if (code == 409) {
            return 'Resource conflict or duplicate record found (HTTP 409).';
          } else if (code == 422) {
            return 'Validation error. Please check your entered details (HTTP 422).';
          } else if (code == 429) {
            return 'Too many requests. Please wait a moment and try again (HTTP 429).';
          } else if (code != null && code >= 500) {
            return 'Server error (HTTP $code). Service is temporarily unavailable. Please try again.';
          }
          return 'Server returned error status ${code ?? 'unknown'}.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the catering server. Please check your internet connection or server availability [Connection Error].';
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return error.message ?? 'An unexpected network error occurred.';
      }
    }
    return error.toString().replaceAll('Exception: ', '');
  }
}