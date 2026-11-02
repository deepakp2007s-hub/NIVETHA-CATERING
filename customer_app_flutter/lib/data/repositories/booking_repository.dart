import '../models/booking_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await _dio.get(ApiConfig.bookings);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: ${e.toString()}');
    }
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _dio.post(
        ApiConfig.bookings,
        data: booking.toJson(),
      );
      return BookingModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to create booking inquiry: ${e.toString()}');
    }
  }

  Future<BookingModel> getBookingDetail(String bookingId) async {
    try {
      final response = await _dio.get('${ApiConfig.bookings}/$bookingId');
      return BookingModel.fromJson(response.data['data'] ?? response.data);
    } catch (e) {
      throw Exception('Failed to fetch booking details: ${e.toString()}');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _dio.patch('${ApiConfig.bookings}/$bookingId/cancel');
    } catch (e) {
      throw Exception('Failed to cancel booking: ${e.toString()}');
    }
  }
}