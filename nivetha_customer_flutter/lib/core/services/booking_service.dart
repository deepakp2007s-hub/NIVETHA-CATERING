
import '../config/api_config.dart';
import 'api_service.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> bookingData,
  }) async {
    if (bookingData.isEmpty) {
      throw ArgumentError('Booking details cannot be empty.');
    }

    final eventType = bookingData['eventType'];
    final eventDate = bookingData['eventDate'];
    final eventLocation = bookingData['eventLocation'];
    final persons = int.tryParse(
      '${bookingData['numberOfPersons'] ?? ''}',
    );

    if (eventType is! String || eventType.trim().isEmpty) {
      throw ArgumentError('Please select an event type.');
    }

    if (eventDate is! String || eventDate.trim().isEmpty) {
      throw ArgumentError('Please select an event date.');
    }

    if (eventLocation is! String || eventLocation.trim().isEmpty) {
      throw ArgumentError('Please enter the event location.');
    }

    if (persons == null || persons < 10) {
      throw ArgumentError(
        'Catering service requires a minimum of 10 persons.',
      );
    }

    final response = await ApiService.instance.post(
      ApiConfig.bookingsEndpoint,
      body: bookingData,
      authenticated: true,
    );

    return _extractBooking(response);
  }

  Future<List<Map<String, dynamic>>> getMyBookings({
    Map<String, String>? queryParameters,
  }) async {
    final response = await ApiService.instance.get(
      '${ApiConfig.bookingsEndpoint}/my',
      queryParameters: queryParameters,
      authenticated: true,
    );

    dynamic items = response;

    if (items is Map) {
      final root = Map<String, dynamic>.from(items);
      items = root['bookings'] ?? root['data'] ?? root['results'] ?? [];
    }

    if (items is Map) {
      final nested = Map<String, dynamic>.from(items);
      items = nested['bookings'] ?? nested['results'] ?? [];
    }

    if (items is! List) {
      throw const FormatException('Invalid bookings list from server.');
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getBookingById(String id) async {
    _validateId(id);

    final response = await ApiService.instance.get(
      '${ApiConfig.bookingsEndpoint}/${Uri.encodeComponent(id.trim())}',
      authenticated: true,
    );

    return _extractBooking(response);
  }

  Future<Map<String, dynamic>> cancelBooking({
    required String id,
    String? reason,
  }) async {
    _validateId(id);

    final cleanReason = reason?.trim();

    final response = await ApiService.instance.patch(
      '${ApiConfig.bookingsEndpoint}/${Uri.encodeComponent(id.trim())}/cancel',
      body: {
        if (cleanReason != null && cleanReason.isNotEmpty)
          'reason': cleanReason,
      },
      authenticated: true,
    );

    return _extractBooking(response);
  }

  Map<String, dynamic> _extractBooking(dynamic response) {
    if (response is! Map) {
      throw const FormatException('Invalid booking response from server.');
    }

    final root = Map<String, dynamic>.from(response);

    for (final key in ['booking', 'data']) {
      final value = root[key];

      if (value is Map) {
        final nested = Map<String, dynamic>.from(value);

        if (nested['booking'] is Map) {
          return Map<String, dynamic>.from(nested['booking'] as Map);
        }

        return nested;
      }
    }

    if (root.containsKey('_id') || root.containsKey('id')) {
      return root;
    }

    throw const FormatException('Booking details were not found.');
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }
  }
}
