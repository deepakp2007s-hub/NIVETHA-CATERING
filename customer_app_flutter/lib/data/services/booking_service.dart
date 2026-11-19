import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';

/// Service managing customer event catering bookings, previews,
/// updates, status tracking, and cancellation requests.
class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;

  final Dio _dio = DioClient().dio;
  static const String _cachedBookingsKey = 'customer_cached_bookings';

  BookingService._internal();

  /// Preview booking payload on the server before final submission
  Future<BookingModel> previewBooking(BookingModel booking) async {
    try {
      final response = await _dio.post(
        ApiConfig.previewBooking,
        data: booking.toCreateJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['booking'] ?? response.data)
            : response.data;
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to preview booking.');
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Submit a new event catering booking
  Future<BookingModel> createBooking(BookingModel booking) async {
    try {
      final response = await _dio.post(
        ApiConfig.createBooking,
        data: booking.toCreateJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['booking'] ?? response.data)
            : response.data;
        final created = BookingModel.fromJson(data);

        await _saveBookingLocally(created);
        return created;
      }
      throw Exception('Failed to submit catering request.');
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Edit an existing pending booking
  Future<BookingModel> updateBooking(
    String bookingId,
    BookingModel booking,
  ) async {
    try {
      final response = await _dio.put(
        ApiConfig.bookingById(bookingId),
        data: booking.toCreateJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['booking'] ?? response.data)
            : response.data;
        final updated = BookingModel.fromJson(data);
        await _updateBookingInCache(updated);
        return updated;
      }
      throw Exception('Failed to update booking.');
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Retrieve bookings created by the authenticated customer (paginated)
  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.myBookings,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['bookings'] ?? []);

        final bookings =
            items.map((json) => BookingModel.fromJson(json)).toList();

        if (page == 1) {
          await _cacheAllBookings(bookings);
        }
        return bookings;
      }
      return await _loadCachedBookings();
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception(DioClient.getErrorMessage(e));
      }
      final cached = await _loadCachedBookings();
      if (cached.isNotEmpty) {
        return cached;
      }
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Cancel a pending booking request
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch(
        ApiConfig.cancelBooking(bookingId),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? (response.data['booking'] ?? response.data)
            : response.data;
        final updated = BookingModel.fromJson(data);
        await _updateBookingInCache(updated);
        return updated;
      }
      throw Exception('Failed to cancel booking.');
    } catch (e) {
      throw Exception(DioClient.getErrorMessage(e));
    }
  }

  /// Clear local booking cache on logout
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedBookingsKey);
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // LOCAL CACHING HELPERS
  // ---------------------------------------------------------------------------

  Future<void> _saveBookingLocally(BookingModel booking) async {
    try {
      final list = await _loadCachedBookings();
      list.insert(0, booking);
      await _cacheAllBookings(list);
    } catch (_) {}
  }

  Future<void> _updateBookingInCache(BookingModel booking) async {
    try {
      final list = await _loadCachedBookings();
      final idx = list.indexWhere((b) => b.id == booking.id);
      if (idx != -1) {
        list[idx] = booking;
      } else {
        list.insert(0, booking);
      }
      await _cacheAllBookings(list);
    } catch (_) {}
  }

  Future<void> _cacheAllBookings(List<BookingModel> bookings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = bookings.map((b) => b.toJson()).toList();
      await prefs.setString(_cachedBookingsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<BookingModel>> _loadCachedBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_cachedBookingsKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List decoded = jsonDecode(jsonStr);
        return decoded.map((j) => BookingModel.fromJson(j)).toList();
      }
    } catch (_) {}
    return [];
  }
}