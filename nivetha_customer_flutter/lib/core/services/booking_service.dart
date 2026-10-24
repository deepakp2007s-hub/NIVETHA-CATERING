
import '../config/api_config.dart';
import 'api_service.dart';

class BookingService {
  BookingService._();

  static final BookingService instance = BookingService._();

  Future<Map<String, dynamic>> createBooking({
    required Map<String, dynamic> bookingData,
  }) async {
    final response = await ApiService.instance.post(
      ApiConfig.bookingsEndpoint,
      body: bookingData,
    );

    return _toMap(response);
  }

  Future<List<Map<String, dynamic>>> getMyBookings({
    Map<String, String>? queryParameters,
  }) async {
    final response = await ApiService.instance.get(
      ApiConfig.bookingsEndpoint,
      queryParameters: queryParameters,
    );

    return _toList(response);
  }

  Future<Map<String, dynamic>> getBookingById(
    String id,
  ) async {
    _validateId(id);

    final response = await ApiService.instance.get(
      '${ApiConfig.bookingsEndpoint}/${Uri.encodeComponent(id)}',
    );

    return _toMap(response);
  }

  Future<Map<String, dynamic>> updateBooking({
    required String id,
    required Map<String, dynamic> bookingData,
  }) async {
    _validateId(id);

    final response = await ApiService.instance.put(
      '${ApiConfig.bookingsEndpoint}/${Uri.encodeComponent(id)}',
      body: bookingData,
    );

    return _toMap(response);
  }

  Future<Map<String, dynamic>> cancelBooking({
    required String id,
    String? reason,
  }) async {
    _validateId(id);

    final response = await ApiService.instance.put(
      '${ApiConfig.bookingsEndpoint}/${Uri.encodeComponent(id)}/cancel',
      body: {
        if (reason != null && reason.trim().isNotEmpty)
          'reason': reason.trim(),
      },
    );

    return _toMap(response);
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError('Booking ID cannot be empty.');
    }
  }

  Map<String, dynamic> _toMap(dynamic response) {
    if (response is Map) {
      final map = Map<String, dynamic>.from(response);
      final data = map['data'];

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      return map;
    }

    throw const FormatException(
      'Invalid booking response from server.',
    );
  }

  List<Map<String, dynamic>> _toList(dynamic response) {
    dynamic value = response;

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      value = map['data'] ??
          map['bookings'] ??
          map['results'] ??
          map['items'] ??
          [];
    }

    if (value is! List) {
      throw const FormatException(
        'Invalid bookings list returned by server.',
      );
    }

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
