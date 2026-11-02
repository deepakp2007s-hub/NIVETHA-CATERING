class ApiConfig {
  static const String baseUrl = 'https://nivetha-fastapi-backend.onrender.com/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';

  // Catalog & Food Endpoints
  static const String categories = '/categories';
  static const String foods = '/foods';
  static const String foodDetails = '/foods/';
  static const String favorites = '/favorites';

  // Booking Endpoints
  static const String bookings = '/bookings';

  // Profile & Address Endpoints
  static const String profile = '/customer/profile';
  static const String addresses = '/customer/addresses';
  static const String notifications = '/notifications';
}