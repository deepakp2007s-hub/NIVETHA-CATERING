class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nivetha-fastapi-backend.onrender.com/api/v1',
  );

  static String get normalizedBaseUrl {
    final uri = Uri.tryParse(baseUrl.trim());
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      throw const ApiConfigurationException('API_BASE_URL is invalid.');
    }

    final localHost = const {'localhost', '127.0.0.1', '10.0.2.2'}
        .contains(uri.host);
    if (uri.scheme != 'https' && !(uri.scheme == 'http' && localHost)) {
      throw const ApiConfigurationException(
        'API_BASE_URL must use HTTPS except for local development.',
      );
    }
    return baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}

class ApiConfigurationException implements Exception {
  const ApiConfigurationException(this.message);
  final String message;

  @override
  String toString() => message;
}
