import '../models/notification_model.dart';
import '../../core/config/api_config.dart';
import 'package:dio/dio.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(ApiConfig.notifications);
      final List data = response.data['data'] ?? response.data ?? [];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: ${e.toString()}');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dio.patch('${ApiConfig.notifications}/$notificationId/read');
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  Future<void> clearAll() async {
    try {
      await _dio.delete(ApiConfig.notifications);
    } catch (e) {
      throw Exception('Failed to clear notifications: ${e.toString()}');
    }
  }
}