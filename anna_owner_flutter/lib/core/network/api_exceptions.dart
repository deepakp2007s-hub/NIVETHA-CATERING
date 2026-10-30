import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  factory ApiException.fromDio(DioException exception) {
    final responseData = exception.response?.data;

    String message = 'Something went wrong. Please try again.';

    if (responseData is Map) {
      final detail = responseData['detail'];

      if (detail is String && detail.isNotEmpty) {
        message = detail;
      } else if (detail is Map) {
        message = detail['message']?.toString() ?? message;
      } else if (responseData['message'] is String) {
        message = responseData['message'];
      }
    }

    if (exception.response?.statusCode == 401) {
      message = 'Invalid owner email or password.';
    } else if (exception.response?.statusCode == 503) {
      message = 'Server or database is temporarily unavailable.';
    }

    return ApiException(
      message: message,
      statusCode: exception.response?.statusCode,
    );
  }

  @override
  String toString() => message;
}