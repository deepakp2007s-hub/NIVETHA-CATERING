
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_storage_service.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  Future<Map<String, String>> _headers({
    bool authenticated = false,
    Map<String, String>? additionalHeaders,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    if (authenticated) {
      final token = await AuthStorageService.getToken();

      if (token != null && token.trim().isNotEmpty) {
        headers['Authorization'] = 'Bearer ${token.trim()}';
      }
    }

    return headers;
  }

  Uri _uri(
    String path, [
    Map<String, String>? queryParameters,
  ]) {
    final uri = Uri.parse(ApiConfig.endpoint(path));

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.body.trim().isEmpty) {
      return null;
    }

    try {
      return jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'Server returned an invalid response.',
        statusCode: response.statusCode,
        responseBody: response.body,
      );
    }
  }

  dynamic _handleResponse(http.Response response) {
    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = 'Request failed. Please try again.';

    if (data is Map) {
      final serverMessage =
          data['message'] ?? data['error'] ?? data['detail'];

      if (serverMessage is String && serverMessage.trim().isNotEmpty) {
        message = serverMessage.trim();
      }
    }

    if (response.statusCode == 401) {
      message = 'Session expired or authentication is required.';
    } else if (response.statusCode == 403) {
      message = 'You do not have permission to perform this action.';
    } else if (response.statusCode == 404) {
      message = 'Requested resource was not found.';
    } else if (response.statusCode >= 500) {
      message = 'Server error. Please try again later.';
    }

    throw ApiException(
      message,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = false,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(
            _uri(path, queryParameters),
            headers: await _headers(
              authenticated: authenticated,
              additionalHeaders: headers,
            ),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            _uri(path),
            headers: await _headers(
              authenticated: authenticated,
              additionalHeaders: headers,
            ),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .put(
            _uri(path),
            headers: await _headers(
              authenticated: authenticated,
              additionalHeaders: headers,
            ),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            _uri(path),
            headers: await _headers(
              authenticated: authenticated,
              additionalHeaders: headers,
            ),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    }
  }

  void close() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? responseBody;

  const ApiException(
    this.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => message;
}
