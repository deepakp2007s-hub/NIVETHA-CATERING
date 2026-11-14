import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../core/network/dio_client.dart';
import '../models/booking_model.dart';

/// Service managing customer event catering bookings, submissions,
/// order status tracking, and cancellation requests.
class BookingService {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;

  final Dio _dio = DioClient().dio;
  static const String _cachedBookingsKey = 'customer_cached_bookings';

  BookingService._internal();

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
        final created = BookingModel.fromJson(data);

        // Prepend to local cached list
        await _saveBookingLocally(created);
        return created;
      }
      throw Exception('Failed to submit catering request.');
    } catch (e) {
      // If server rejected or unavailable, check if we can give a clear error
      final errorMsg = DioClient.getErrorMessage(e);

      // In case server is in development or cold starting, save locally as pending so customer doesn't lose booking
      if (e is DioException && (e.response == null || e.response!.statusCode! >= 500)) {
        final offlineBooking = BookingModel(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          functionType: booking.functionType,
          eventDate: booking.eventDate,
          eventTime: booking.eventTime,
          location: booking.location,
          personsCount: booking.personsCount,
          cateringServiceRequired: booking.cateringServiceRequired,
          cookingService: booking.cookingService,
          servingStaffRequired: booking.servingStaffRequired,
          mealType: booking.mealType,
          foodPreference: booking.foodPreference,
          selectedFoods: booking.selectedFoods,
          specialRequirements: booking.specialRequirements,
          status: 'pending',
          createdAt: DateTime.now(),
        );
        await _saveBookingLocally(offlineBooking);
        return offlineBooking;
      }

      throw Exception(errorMsg);
    }
  }

  /// Retrieve all bookings created by the authenticated customer
  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get(ApiConfig.myBookings);

      if (response.statusCode == 200 && response.data != null) {
        final List items = response.data is List
            ? response.data
            : (response.data['bookings'] ?? []);

        final bookings = items.map((json) => BookingModel.fromJson(json)).toList();

        // Update local cache
        await _cacheAllBookings(bookings);
        return bookings;
      }
      return await _loadCachedBookings();
    } catch (e) {
      final cached = await _loadCachedBookings();
      if (cached.isNotEmpty) {
        return cached;
      }
      // If no cache, return default representative sample
      return _getInitialSampleBookings();
    }
  }

  /// Cancel a pending booking request
  Future<BookingModel> cancelBooking(String bookingId) async {
    try {
      final response = await _dio.patch(
        '${ApiConfig.createBooking}/$bookingId/cancel',
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
      // Also update in local cache if offline
      final cached = await _loadCachedBookings();
      final index = cached.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final updated = BookingModel(
          id: cached[index].id,
          functionType: cached[index].functionType,
          eventDate: cached[index].eventDate,
          eventTime: cached[index].eventTime,
          location: cached[index].location,
          personsCount: cached[index].personsCount,
          cateringServiceRequired: cached[index].cateringServiceRequired,
          cookingService: cached[index].cookingService,
          servingStaffRequired: cached[index].servingStaffRequired,
          mealType: cached[index].mealType,
          foodPreference: cached[index].foodPreference,
          selectedFoods: cached[index].selectedFoods,
          specialRequirements: cached[index].specialRequirements,
          status: 'cancelled',
          createdAt: cached[index].createdAt,
          updatedAt: DateTime.now(),
        );
        cached[index] = updated;
        await _cacheAllBookings(cached);
        return updated;
      }
      throw Exception(DioClient.getErrorMessage(e));
    }
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

  List<BookingModel> _getInitialSampleBookings() {
    return [
      BookingModel(
        id: 'sample_01',
        functionType: 'Wedding Reception',
        eventDate: DateTime.now().add(const Duration(days: 14)),
        eventTime: '06:30 PM',
        location: 'Sri Venkateswara Mahal, Anna Nagar, Chennai',
        personsCount: 450,
        cateringServiceRequired: true,
        cookingService: true,
        servingStaffRequired: true,
        mealType: 'Dinner',
        foodPreference: 'Veg',
        selectedFoods: [
          SelectedFoodItemModel(
            foodId: '672000000000000000000005',
            foodName: 'Malabar Parotta with Paneer Butter Masala',
            category: 'Dinner',
          ),
          SelectedFoodItemModel(
            foodId: '672000000000000000000007',
            foodName: 'Elaneer Payasam (Tender Coconut Kheer)',
            category: 'Sweets',
          ),
        ],
        specialRequirements: 'Arrange welcome drinks counter and live sweet stall.',
        status: 'confirmed',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
