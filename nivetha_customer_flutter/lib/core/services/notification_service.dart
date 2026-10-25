
import '../config/api_config.dart';
import 'api_service.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final ApiService _api = ApiService.instance;

  /// Fetch notifications for the logged-in customer.
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _api.get(
      ApiConfig.notificationsEndpoint,
      authenticated: true,
    );

    return _extractNotifications(response);
  }

  /// Get the number of unread notifications.
  Future<int> getUnreadCount() async {
    final response = await _api.get(
      ApiConfig.notificationsEndpoint,
      authenticated: true,
    );

    if (response is Map) {
      final root = Map<String, dynamic>.from(response);
      final count = root['unreadCount'];

      if (count is num) return count.toInt();

      return int.tryParse(count?.toString() ?? '') ?? 0;
    }

    throw const ApiException(
      'Notification server returned an unexpected response.',
    );
  }

  /// Mark one notification as read.
  Future<Map<String, dynamic>> markAsRead(
    String notificationId,
  ) async {
    final id = notificationId.trim();

    if (id.isEmpty) {
      throw const ApiException('Notification ID is required.');
    }

    final response = await _api.patch(
      '${ApiConfig.notificationsEndpoint}/${Uri.encodeComponent(id)}/read',
      authenticated: true,
    );

    return _extractNotification(response);
  }

  /// Mark all notifications as read.
  Future<int> markAllAsRead() async {
    final response = await _api.patch(
      '${ApiConfig.notificationsEndpoint}/read-all',
      authenticated: true,
    );

    if (response is Map) {
      final root = Map<String, dynamic>.from(response);
      final count = root['modifiedCount'];

      if (count is num) return count.toInt();

      return int.tryParse(count?.toString() ?? '') ?? 0;
    }

    return 0;
  }

  List<Map<String, dynamic>> _extractNotifications(dynamic response) {
    if (response is! Map) {
      throw const ApiException(
        'Notification server returned an unexpected response.',
      );
    }

    final root = Map<String, dynamic>.from(response);

    if (root['success'] == false) {
      throw ApiException(
        root['message']?.toString() ?? 'Failed to load notifications.',
      );
    }

    dynamic items = root['notifications'] ?? root['data'];

    if (items is Map) {
      final nested = Map<String, dynamic>.from(items);
      items = nested['notifications'] ?? nested['results'] ?? nested['items'];
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

  Map<String, dynamic> _extractNotification(dynamic response) {
    if (response is Map) {
      final root = Map<String, dynamic>.from(response);

      if (root['success'] == false) {
        throw ApiException(
          root['message']?.toString() ?? 'Notification update failed.',
        );
      }

      final notification = root['notification'] ?? root['data'];

      if (notification is Map) {
        return Map<String, dynamic>.from(notification);
      }

      return root;
    }

    throw const ApiException(
      'Unexpected notification response.',
    );
  }
}
