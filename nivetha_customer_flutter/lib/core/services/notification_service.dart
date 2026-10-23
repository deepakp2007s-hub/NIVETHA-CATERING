
import 'api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final ApiService _api = ApiService.instance;

  static const String notificationsEndpoint = '/notifications';

  Future<List<Map<String, dynamic>>> getNotifications({
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Please log in to view notifications.');
    }

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

    if (items is Map) {
      items = items['notifications'] ??
          items['items'] ??
          items['data'];
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
    if (token.trim().isEmpty) {
      throw Exception('Please log in to update notifications.');
    }

    if (notificationId.trim().isEmpty) {
      throw ArgumentError('Notification ID cannot be empty.');
    }

    final response = await _api.patch(
      '$notificationsEndpoint/${Uri.encodeComponent(notificationId)}/read',
      token: token,
      body: <String, dynamic>{},
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> markAllAsRead({
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Please log in to update notifications.');
    }

    final response = await _api.patch(
      '$notificationsEndpoint/read-all',
      token: token,
      body: <String, dynamic>{},
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> deleteNotification({
    required String notificationId,
    required String token,
  }) async {
    if (token.trim().isEmpty) {
      throw Exception('Please log in to delete notifications.');
    }

    if (notificationId.trim().isEmpty) {
      throw ArgumentError('Notification ID cannot be empty.');
    }

    final response = await _api.delete(
      '$notificationsEndpoint/${Uri.encodeComponent(notificationId)}',
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

    throw Exception('Invalid notification response from server.');
  }
}
