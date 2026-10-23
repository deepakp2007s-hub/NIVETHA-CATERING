
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final http.Client _client = http.Client();

  Uri _buildUri(String path) {
    final base = Uri.parse('${ApiConfig.baseUrl}/');
    final normalizedPath =
        path.startsWith('/') ? path.substring(1) : path;

    return base.resolve(normalizedPath);
  }

  Map<String, String> _headers(String? token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(
    String path, {
    String? token,
  }) async {
    try {
      final response = await _client
          .get(
            _buildUri(path),
            headers: _headers(token),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Server took too long to respond. Try again.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final response = await _client
          .post(
            _buildUri(path),
            headers: _headers(token),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Server took too long to respond. Try again.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    }
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final response = await _client
          .patch(
            _buildUri(path),
            headers: _headers(token),
            body: jsonEncode(body ?? <String, dynamic>{}),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Server took too long to respond. Try again.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    }
  }

  Future<dynamic> delete(
    String path, {
    String? token,
  }) async {
    try {
      final response = await _client
          .delete(
            _buildUri(path),
            headers: _headers(token),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Server took too long to respond. Try again.');
    } on http.ClientException {
      throw Exception('Unable to connect to the server.');
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic data;

    try {
      data = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return data;
    }

    String message = 'Request failed';

    if (data is Map) {
      message = (
        data['message'] ??
        data['error'] ??
        data['errors'] ??
        message
      ).toString();
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }

    throw Exception(
      '$message (HTTP ${response.statusCode})',
    );
  }

  void dispose() {
    _client.close();
  }
}
