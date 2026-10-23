
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  final String? token;

  const NotificationsScreen({
    super.key,
    this.token,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final token = widget.token;

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _error = 'Please sign in to view your notifications.';
        _notifications = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result =
          await NotificationService.instance.getNotifications(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _notifications = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load notifications. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _read(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  bool _isRead(Map<String, dynamic> item) {
    return item['isRead'] == true || item['read'] == true;
  }

  String _notificationId(Map<String, dynamic> item) {
    return _read(item, ['_id', 'id', 'notificationId']);
  }

  IconData _iconFor(String type) {
    final value = type.toLowerCase();

    if (value.contains('confirm')) {
      return Icons.event_available_rounded;
    }
    if (value.contains('cancel') || value.contains('reject')) {
      return Icons.event_busy_rounded;
    }
    if (value.contains('reminder')) {
      return Icons.alarm_rounded;
    }
    if (value.contains('complete')) {
      return Icons.task_alt_rounded;
    }
    if (value.contains('payment')) {
      return Icons.receipt_long_rounded;
    }

    return Icons.notifications_active_rounded;
  }

  Future<void> _markAsRead(
    Map<String, dynamic> item,
  ) async {
    if (_isRead(item)) return;

    final id = _notificationId(item);
    final token = widget.token;

    if (id.isEmpty || token == null || token.isEmpty) {
      return;
    }

    try {
      await NotificationService.instance.markAsRead(
        notificationId: id,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        final index = _notifications.indexOf(item);
        if (index >= 0) {
          _notifications[index] = {
            ..._notifications[index],
            'isRead': true,
            'read': true,
          };
        }
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not mark this notification as read.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        _notifications.where((item) => !_isRead(item)).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryGreenDark,
                  AppColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.goldAccent,
                  size: 38,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stay Updated',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$unreadCount unread notification(s)',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 58,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Icon(
              Icons.notifications_none_rounded,
              size: 70,
              color: AppColors.textLight,
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Booking updates will appear here.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _notifications[index];

          final title = _read(
            item,
            ['title', 'subject'],
            fallback: 'Nivetha Catering Update',
          );

          final message = _read(
            item,
            ['message', 'body', 'description'],
            fallback: 'You have a new update.',
          );

          final type = _read(
            item,
            ['type', 'category'],
            fallback: 'general',
          );

          final isRead = _isRead(item);

          return Material(
            color: isRead
                ? Colors.white
                : AppColors.primaryGreenLight,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _markAsRead(item),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.cardBorder,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.10,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _iconFor(type),
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead
                                  ? FontWeight.w600
                                  : FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to mark as read',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5),
                        decoration: const BoxDecoration(
                          color: AppColors.goldDark,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
