
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://nivetha-fastapi-backend.onrender.com/api/v1',
  );

  static const String ownerLogin = '/auth/owner/login';
  static const String health = '/health';

  static String get validatedBaseUrl {
    final uri = Uri.tryParse(baseUrl);

    if (uri == null || !uri.hasAuthority) {
      throw const ApiConfigurationException(
        'Invalid API base URL configuration.',
      );
    }

    final isHttps = uri.scheme == 'https';
    final isLocalhost = uri.scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '10.0.2.2');

    if (!isHttps && !isLocalhost) {
      throw const ApiConfigurationException(
        'API must use HTTPS in production.',
      );
    }

    return baseUrl.replaceFirst(RegExp(r'/+$'), '');
  }

  static String resolve(String endpoint) {
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';

    return '$validatedBaseUrl$normalizedEndpoint';
  }
}

class ApiConfigurationException implements Exception {
  final String message;

  const ApiConfigurationException(this.message);

  @override
  String toString() => message;
}
