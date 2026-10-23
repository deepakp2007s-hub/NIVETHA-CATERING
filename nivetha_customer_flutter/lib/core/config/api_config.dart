
class ApiConfig {
  ApiConfig._();

  // Nivetha Catering production backend
  static const String baseUrl =
      'https://nivetha-catering-api.onrender.com/api';

  // Maximum time to wait for an API response
  static const Duration connectTimeout =
      Duration(seconds: 20);

  static const Duration receiveTimeout =
      Duration(seconds: 30);
}
