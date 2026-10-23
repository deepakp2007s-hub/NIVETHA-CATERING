
import 'api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final ApiService _api = ApiService.instance;

  // Confirm the endpoint against your deployed backend.
  static const String notificationsEndpoint = '/notifications';

  Future<List<Map<String, dynamic>>> getNotifications({
    required String token,
  }) async {
    final response = await _api.get(
      notificationsEndpoint,
      token: token,
    );

    dynamic items = response;

    if (response is Map) {
      items = response['notifications'] ??
          response['data'] ??
          response['items'];
    }

    if (items is! List) {
      throw Exception(
        'Invalid notifications response received from the server.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Future<Map<String, dynamic>> markAsRead({
    required String notificationId,
    required String token,
  }) async {
    if (notificationId.trim().isEmpty) {
      throw ArgumentError('Notification ID cannot be empty.');
    }

    // Confirm that this PATCH endpoint exists on your backend
    // before calling this method.
    final response = await _api.post(
      '$notificationsEndpoint/$notificationId/read',
      token: token,
      body: const {},
    );

    if (response is Map<String, dynamic>) {
      return response;
    }

    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }

    throw Exception('Invalid notification response from server.');
  }
}
