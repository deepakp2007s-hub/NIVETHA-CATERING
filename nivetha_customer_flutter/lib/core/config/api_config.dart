
class ApiConfig {
  ApiConfig._();

  static const String baseUrl =
      'https://nivetha-catering-api.onrender.com/api';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const String loginEndpoint = '/customer-auth/login';
  static const String registerEndpoint = '/customer-auth/register';

  static const String foodsEndpoint = '/foods';
  static const String bookingsEndpoint = '/bookings';
  static const String notificationsEndpoint = '/notifications';

  static String endpoint(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }

    return '$baseUrl/$path';
  }
}
