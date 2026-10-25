
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'auth_storage_service.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  bool _isClosed = false;

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

      if (token == null || token.trim().isEmpty) {
        throw const ApiException(
          'Please log in to continue.',
          statusCode: 401,
        );
      }

      headers['Authorization'] = 'Bearer ${token.trim()}';
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
    if (response.body.trim().isEmpty) return null;

    try {
      return jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw ApiException(
          'Server returned an invalid response.',
          statusCode: response.statusCode,
          responseBody: response.body,
        );
      }

      return null;
    }
  }

  dynamic _handleResponse(http.Response response) {
    final data = _decodeResponse(response);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final message = switch (response.statusCode) {
      400 => _serverMessageOr(
          data,
          'Invalid request. Please check your information.',
        ),
      401 => _serverMessageOr(
          data,
          'Session expired. Please log in again.',
        ),
      403 => _serverMessageOr(
          data,
          'You do not have permission to perform this action.',
        ),
      404 => _serverMessageOr(
          data,
          'Requested resource was not found.',
        ),
      409 => _serverMessageOr(
          data,
          'This request conflicts with existing information.',
        ),
      422 => _serverMessageOr(
          data,
          'Please check the information you entered.',
        ),
      _ when response.statusCode >= 500 =>
        'Server error. Please try again later.',
      _ => _serverMessageOr(
          data,
          'Request failed. Please try again.',
        ),
    };

    throw ApiException(
      message,
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  String _serverMessageOr(dynamic data, String fallback) {
    if (data is Map) {
      final value = data['message'] ?? data['error'] ?? data['detail'];

      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return fallback;
  }

  void _ensureOpen() {
    if (_isClosed) {
      throw StateError(
        'ApiService has been closed and cannot be used again.',
      );
    }
  }

  Future<dynamic> _sendRequest(
    Future<http.Response> Function(Map<String, String> headers) request, {
    bool authenticated = false,
    Map<String, String>? headers,
  }) async {
    _ensureOpen();

    try {
      final requestHeaders = await _headers(
        authenticated: authenticated,
        additionalHeaders: headers,
      ).timeout(ApiConfig.receiveTimeout);

      final response = await request(
        requestHeaders,
      ).timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please check your connection.',
      );
    } on http.ClientException catch (error) {
      throw ApiException('Network error: ${error.message}');
    } on FormatException {
      throw const ApiException(
        'Unable to process the server response.',
      );
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = false,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      (requestHeaders) => _client.get(
        _uri(path, queryParameters),
        headers: requestHeaders,
      ),
      authenticated: authenticated,
      headers: headers,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      (requestHeaders) => _client.post(
        _uri(path),
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      authenticated: authenticated,
      headers: headers,
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      (requestHeaders) => _client.put(
        _uri(path),
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      authenticated: authenticated,
      headers: headers,
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      (requestHeaders) => _client.patch(
        _uri(path),
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      authenticated: authenticated,
      headers: headers,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Map<String, String>? headers,
  }) {
    return _sendRequest(
      (requestHeaders) => _client.delete(
        _uri(path),
        headers: requestHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      authenticated: authenticated,
      headers: headers,
    );
  }

  void close() {
    if (_isClosed) return;

    _isClosed = true;
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
