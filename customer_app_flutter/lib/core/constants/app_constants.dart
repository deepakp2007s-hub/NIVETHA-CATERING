class AppConstants {
  static const String appName = 'Nivetha Catering';
  static const String apiBaseUrl = 'https://nivetha-fastapi-backend.onrender.com/api/v1';
  
  // Storage Keys
  static const String keyToken = 'jwt_token';
  static const String keyUser = 'user_data';
  
  // Validation Regex
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp phoneRegex = RegExp(r'^\+?[0-9]{10,14}$');
  
  // Pagination & Limits
  static const int defaultPageSize = 20;
}