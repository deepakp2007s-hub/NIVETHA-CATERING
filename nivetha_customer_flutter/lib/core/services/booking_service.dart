
import 'api_service.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  final ApiService _api = ApiService.instance;

  // Backend routes:
  // POST  /api/bookings
  // GET   /api/bookings/my-bookings
  // PATCH /api/bookings/:id/cancel
  // PATCH /api/bookings/:id

  static const String bookingsEndpoint = '/bookings';
  static const String myBookingsEndpoint = '/bookings/my-bookings';

  Future<Map<String, dynamic>> createBooking({
    required String customerType,
    required String functionDate,
    required String functionTime,
    required String location,
    required int numberOfPersons,
    required String foodPreference,
    required List<String> meals,
    String? extraRequirements,
    bool cookingService = false,
    bool servingStaff = false,
    String? token,
  }) async {
    if (numberOfPersons < 1) {
      throw ArgumentError('Number of persons must be at least 1.');
    }

    if (token == null || token.trim().isEmpty) {
      throw Exception('Please log in before creating a booking.');
    }

    final body = <String, dynamic>{
      'customerType': customerType,
      'functionDate': functionDate,
      'functionTime': functionTime,
      'location': location.trim(),
      'numberOfPersons': numberOfPersons,
      'foodPreference': foodPreference,
      'meals': meals,
      'cookingService': cookingService,
      'servingStaff': servingStaff,
      'extraRequirements': extraRequirements?.trim() ?? '',
    };

    final response = await _api.post(
      bookingsEndpoint,
      body: body,
      token: token,
    );

    return _parseResponse(response);
  }

  Future<List<Map<String, dynamic>>> getMyBookings({
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Please log in to view your bookings.');
    }

    final response = await _api.get(
      myBookingsEndpoint,
      token: token,
    );

    dynamic items = response;

    if (response is Map) {
      items = response['bookings'] ??
          response['data'] ??
          response['items'];
      
      if (items is Map) {
        items = items['bookings'] ??
            items['items'] ??
            items['data'];
      }
    }

    if (items is! List) {
      throw Exception(
        'Invalid bookings response received from the server.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> cancelBooking({
    required String bookingId,
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Please log in to cancel a booking.');
    }

    if (bookingId.trim().isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }

    final response = await _api.post(
      // This endpoint uses PATCH, so use the PATCH method
      // available in ApiService when implementing this request.
      '/bookings/${Uri.encodeComponent(bookingId)}/cancel',
      body: <String, dynamic>{},
      token: token,
    );

    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Invalid response received from the server.');
  }
}
