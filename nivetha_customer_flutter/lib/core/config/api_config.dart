
class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://nivetha-catering-api.onrender.com/api';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Customer authentication
  static const String loginEndpoint = '/customer-auth/login';
  static const String registerEndpoint = '/customer-auth/register';

  // Customer app features
  static const String foodsEndpoint = '/foods';
  static const String bookingsEndpoint = '/bookings';
  static const String notificationsEndpoint = '/notifications';

  // Backend health check
  static const String healthEndpoint = '/health';

  static String endpoint(String path) {
    final trimmedPath = path.trim();

    if (trimmedPath.isEmpty) {
      return baseUrl;
    }

    if (trimmedPath.startsWith('http://') ||
        trimmedPath.startsWith('https://')) {
      return trimmedPath;
    }

    final normalizedPath = trimmedPath.startsWith('/')
        ? trimmedPath
        : '/$trimmedPath';

    return '$baseUrl$normalizedPath';
  }
}
