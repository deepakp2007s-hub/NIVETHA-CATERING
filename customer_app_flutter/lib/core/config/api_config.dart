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
  static const String foods = '/foods/';
  static const String foodCategories = '/foods/categories';
  static String foodById(String id) => '/foods/$id';

  // ---------------------------------------------------------------------------
  // BOOKING ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String createBooking = '/bookings/';
  static const String myBookings = '/bookings/my-bookings';
  static const String previewBooking = '/bookings/preview';
  static String bookingById(String id) => '/bookings/$id';
  static String cancelBooking(String id) => '/bookings/$id/cancel';

  // ---------------------------------------------------------------------------
  // PROFILE ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String profile = '/profile/me';

  // ---------------------------------------------------------------------------
  // NOTIFICATION ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String myNotifications = '/notifications/my-notifications';
  static const String unreadNotificationsCount = '/notifications/unread-count';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // ---------------------------------------------------------------------------
  // REVIEW ENDPOINTS
  // ---------------------------------------------------------------------------
  static const String reviews = '/reviews/';
  static const String reviewSummary = '/reviews/summary';
  static const String myReviews = '/reviews/my-reviews';
}