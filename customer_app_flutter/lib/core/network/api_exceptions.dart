import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timed out. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return ApiException(message: 'No internet connection available.');
      case DioExceptionType.badResponse:
        return _handleBadResponse(dioException.response);
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled.');
      default:
        return ApiException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Server error occurred.';
    if (data is Map<String, dynamic> && data.containsKey('detail')) {
      final detail = data['detail'];
      if (detail is String) {
        message = detail;
      } else if (detail is List) {
        message = detail.map((e) => e.toString()).join(', ');
      }
    }

    switch (statusCode) {
      case 400:
        return ApiException(message: message, statusCode: 400);
      case 401:
        return ApiException(message: message.isNotEmpty ? message : 'Unauthorized. Please login again.', statusCode: 401);
      case 403:
        return ApiException(message: message.isNotEmpty ? message : 'Access forbidden.', statusCode: 403);
      case 404:
        return ApiException(message: message.isNotEmpty ? message : 'Requested resource not found.', statusCode: 404);
      case 500:
      case 502:
      case 503:
        return ApiException(message: 'Internal server error. Please try again later.', statusCode: statusCode);
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }

  @override
  String toString() => message;
}