/// API Configuration for NIVETHA Customer Catering Application.
///
/// Contains backend base URL and route constants compatible with
/// both the live Render deployment and local development environments.
class ApiConfig {
  // Live Render backend URL (can be swapped to http://10.0.2.2:8000 for local emulator)
  static const String baseUrl =
      'https://nivetha-catering-backend.onrender.com/api/v1';

  // Alternative local dev URL if needed
  static const String localBaseUrl = 'http://10.0.2.2:8000/api/v1';

  // ---------------------------------------------------------------------------
  // AUTHENTICATION ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String customerLogin = '/auth/customer/login';
  static const String login = '/auth/login';
  static const String customerRegister = '/auth/customer/register';
  static const String register = '/auth/register';

  // ---------------------------------------------------------------------------
  // FOOD CATALOG ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String foods = '/foods';
  static const String foodCategories = '/foods/categories';

  // ---------------------------------------------------------------------------
  // BOOKING ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String createBooking = '/bookings';
  static const String myBookings = '/bookings/my-bookings';
  static const String previewBooking = '/bookings/preview';

  // ---------------------------------------------------------------------------
  // PROFILE ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String profile = '/profile/me';
}
