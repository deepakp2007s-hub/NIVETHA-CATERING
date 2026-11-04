import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';

class BookingService {
  final Dio _dio = DioClient().dio;

  /// Submit a new event catering booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _dio.post(
        ApiConfig.createBooking,
        data: booking.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['booking'] ?? response.data)
            : response.data;
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to submit booking request.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Booking submission failed.',
      );
    }
  }

  /// Retrieve all bookings created by authenticated customer
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConfig.myBookings);

      if (response.statusCode == 200) {
        final List items = response.data is List
            ? response.data
            : (response.data['bookings'] ?? []);
        return items.map((json) => BookingModel.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Failed to retrieve booking history.',
      );
    }
  }

  /// Cancel a pending booking request
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch('${ApiConfig.createBooking}/$bookingId/cancel');

      if (response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['booking'] ?? response.data)
            : response.data;
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to cancel booking.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['detail'] ?? e.message ?? 'Cancellation failed.',
      );
    }
  }
}