
import '../config/api_config.dart';
import 'api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final ApiService _api = ApiService.instance;

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _api.get(
      ApiConfig.notificationsEndpoint,
      authenticated: true,
    );

    return _extractNotifications(response);
  }

  Future<Map<String, dynamic>> markAsRead(
    String notificationId,
  ) async {
    if (notificationId.trim().isEmpty) {
      throw const ApiException('Notification ID is required.');
    }

    final response = await _api.put(
      '${ApiConfig.notificationsEndpoint}/${Uri.encodeComponent(notificationId)}/read',
      body: <String, dynamic>{},
      authenticated: true,
    );

    return _asMap(response);
  }

  Future<void> markAllAsRead() async {
    await _api.put(
      '${ApiConfig.notificationsEndpoint}/read-all',
      body: <String, dynamic>{},
      authenticated: true,
    );
  }

  List<Map<String, dynamic>> _extractNotifications(dynamic response) {
    dynamic items = response;

    if (response is Map) {
      items = response['notifications'] ??
          response['data'] ??
          response['results'] ??
          response['items'];
    }

    if (items is! List) {
      throw const ApiException(
        'Notification server returned an unexpected response.',
      );
    }

    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is Map) {
      final data = response['notification'] ?? response['data'] ?? response;

      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }

    throw const ApiException(
      'Unexpected notification response.',
    );
  }
}
