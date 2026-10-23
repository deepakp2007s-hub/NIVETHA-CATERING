
import 'api_service.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  final ApiService _api = ApiService.instance;

  // Confirm this endpoint against the deployed backend.
  static const String bookingsEndpoint = '/bookings';

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
    final response = await _api.get(
      bookingsEndpoint,
      token: token,
    );

    dynamic items = response;

    if (response is Map) {
      items = response['bookings'] ??
          response['data'] ??
          response['items'];
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
