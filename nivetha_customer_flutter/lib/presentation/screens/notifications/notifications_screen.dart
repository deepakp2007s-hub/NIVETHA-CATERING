
import 'package:flutter/material.dart';

import '../../../core/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color _cream = Color(0xFFFFF8ED);
  static const Color _darkBrown = Color(0xFF402719);
  static const Color _brown = Color(0xFF765039);
  static const Color _gold = Color(0xFFD5A64A);
  static const Color _lightGold = Color(0xFFF5E5C2);

  final ApiService _api = ApiService.instance;

  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;
  String? _errorMessage;
  int _serverUnreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  int get _unreadCount {
    final localUnread = _notifications.where((n) => n['read'] != true).length;
    return localUnread > _serverUnreadCount ? localUnread : _serverUnreadCount;
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications.where((n) => n['read'] != true).toList();
      case 'Bookings':
        return _notifications
            .where((n) => _categoryOf(n) == 'Bookings')
            .toList();
      case 'Payments':
        return _notifications
            .where((n) => _categoryOf(n) == 'Payments')
            .toList();
      default:
        return _notifications;
    }
  }

  String _stringValue(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    return value.toString().trim();
  }

  bool _isRead(Map<String, dynamic> notification) {
    final value = notification['read'] ?? notification['isRead'];
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  String _categoryOf(Map<String, dynamic> notification) {
    final value = _stringValue(
      notification['category'] ?? notification['type'],
      'General',
    ).toLowerCase();

    if (value.contains('book')) return 'Bookings';
    if (value.contains('payment')) return 'Payments';
    return 'General';
  }

  IconData _iconFor(Map<String, dynamic> notification) {
    final category = _categoryOf(notification);
    final text = '${notification['title'] ?? ''} '
            '${notification['message'] ?? ''}'
        .toLowerCase();

    if (category == 'Bookings') return Icons.event_available_rounded;
    if (category == 'Payments') return Icons.payments_rounded;
    if (text.contains('cancel')) return Icons.event_busy_rounded;
    if (text.contains('food') || text.contains('menu')) {
      return Icons.restaurant_menu_rounded;
    }
    if (text.contains('welcome')) return Icons.celebration_rounded;
    return Icons.notifications_active_rounded;
  }

  Color _colorFor(Map<String, dynamic> notification) {
    switch (_categoryOf(notification)) {
      case 'Bookings':
        return const Color(0xFFE7ECDD);
      case 'Payments':
        return const Color(0xFFF5E5C2);
      default:
        return const Color(0xFFECE4F5);
    }
  }

  String _formatTime(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 'Recently';
    }

    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();

    final localDate = date.toLocal();
    final difference = DateTime.now().difference(localDate);

    if (difference.isNegative || difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _api.get('notifications');

      final rawNotifications = response['notifications'];
      final loadedNotifications = <Map<String, dynamic>>[];

      if (rawNotifications is List) {
        for (final item in rawNotifications) {
          if (item is! Map) continue;

          final notification = Map<String, dynamic>.from(item);

          loadedNotifications.add({
            ...notification,
            'title': _stringValue(
              notification['title'],
              'Nivetha Update',
            ),
            'message': _stringValue(
              notification['message'] ?? notification['body'],
              'You have a new notification.',
            ),
            'read': _isRead(notification),
          });
        }
      }

      final unreadValue = response['unreadCount'];
      final unreadCount = unreadValue is num
          ? unreadValue.toInt()
          : int.tryParse(unreadValue?.toString() ?? '') ?? 0;

      if (!mounted) return;

      setState(() {
        _notifications = loadedNotifications;
        _serverUnreadCount = unreadCount;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Could not load notifications. Check your connection and try again.';
      });
    }
  }

  String? _notificationId(Map<String, dynamic> notification) {
    final id = notification['_id'] ?? notification['id'];
    if (id == null || id.toString().trim().isEmpty) return null;
    return id.toString();
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    if (_isRead(notification)) return;

    final id = _notificationId(notification);
    if (id == null) {
      _showMessage('This notification has no server ID.');
      return;
    }

    final index = _notifications.indexOf(notification);
    if (index < 0) return;

    setState(() {
      _notifications[index]['read'] = true;
    });

    try {
      await _api.patch('notifications/$id/read');
      if (!mounted) return;
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _notifications[index]['read'] = false;
      });
      _showMessage('Could not mark notification as read.');
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAll || _unreadCount == 0) return;

    setState(() => _isMarkingAll = true);

    try {
      await _api.patch('notifications/read-all');

      if (!mounted) return;

      setState(() {
        for (final notification in _notifications) {
          notification['read'] = true;
        }
        _serverUnreadCount = 0;
        _isMarkingAll = false;
      });

      _showMessage('All notifications marked as read.');
      await _loadNotifications();
    } catch (error) {
      if (!mounted) return;

      setState(() => _isMarkingAll = false);
      _showMessage('Could not mark all notifications as read.');
    }
  }

  Future<void> _confirmClearNotifications() async {
    if (_notifications.isEmpty) return;

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'Clear notifications?',
          style: TextStyle(
            color: _darkBrown,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: const Text(
          'This removes notifications from the current screen only. '
          'It does not delete them from the server.',
          style: TextStyle(color: _brown, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _brown),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkBrown,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !mounted) return;

    setState(() {
      _notifications = [];
    });

    _showMessage('Notifications cleared from this screen.');
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _filteredNotifications;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _darkBrown,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: _darkBrown,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed: _isMarkingAll ? null : _markAllAsRead,
              icon: _isMarkingAll
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _darkBrown,
                      ),
                    )
                  : const Icon(
                      Icons.done_all_rounded,
                      color: _darkBrown,
                    ),
            ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            icon: const Icon(
              Icons.more_vert_rounded,
              color: _darkBrown,
            ),
            onSelected: (value) {
              if (value == 'read') {
                _markAllAsRead();
              } else if (value == 'clear') {
                _confirmClearNotifications();
              } else if (value == 'refresh') {
                _loadNotifications();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Refresh'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Clear screen'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: _buildSummaryCard(),
          ),
          SizedBox(
            height: 43,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _filterChip('All'),
                _filterChip('Unread'),
                _filterChip('Bookings'),
                _filterChip('Payments'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildNotificationContent(notifications),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContent(
    List<Map<String, dynamic>> notifications,
  ) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _gold),
      );
    }

    if (_errorMessage != null && _notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 55,
                color: _brown,
              ),
              const SizedBox(height: 15),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _brown,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _darkBrown,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: _darkBrown,
      onRefresh: _loadNotifications,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(notifications[index]);
        },
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF503322), Color(0xFF2E1B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: _gold.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: _gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay in the Loop',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _unreadCount == 0
                      ? 'You are all caught up!'
                      : 'You have $_unreadCount unread notification'
                          '${_unreadCount == 1 ? '' : 's'}.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_unreadCount',
                style: const TextStyle(
                  color: _darkBrown,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 9),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _selectedFilter = label);
        },
        selectedColor: _darkBrown,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? _darkBrown : _lightGold,
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : _brown,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = _isRead(notification);
    final title = _stringValue(notification['title'], 'Nivetha Update');
    final message = _stringValue(
      notification['message'],
      'You have a new notification.',
    );
    final time = _formatTime(
      notification['createdAt'] ??
          notification['created_at'] ??
          notification['time'],
    );

    return InkWell(
      onTap: isRead ? null : () => _markAsRead(notification),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFFFFDF8),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isRead
                ? _lightGold
                : _gold.withValues(alpha: 0.75),
            width: isRead ? 1 : 1.3,
          ),
          boxShadow: [
            if (!isRead)
              BoxShadow(
                color: _gold.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 49,
              height: 49,
              decoration: BoxDecoration(
                color: _colorFor(notification),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _iconFor(notification),
                color: _darkBrown,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: _darkBrown,
                            fontSize: 13,
                            fontWeight: isRead
                                ? FontWeight.w700
                                : FontWeight.w900,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(
                            left: 8,
                            top: 5,
                          ),
                          decoration: const BoxDecoration(
                            color: _gold,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    message,
                    style: TextStyle(
                      color: _brown.withValues(alpha: 0.85),
                      fontSize: 11.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      if (!isRead)
                        const Text(
                          'NEW',
                          style: TextStyle(
                            color: _brown,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedFilter != 'All';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 115,
              height: 115,
              decoration: const BoxDecoration(
                color: _lightGold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 57,
                color: _darkBrown,
              ),
            ),
            const SizedBox(height: 23),
            Text(
              isFiltered ? 'Nothing to Show' : 'All Caught Up!',
              style: const TextStyle(
                color: _darkBrown,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              isFiltered
                  ? 'There are no notifications in this category.'
                  : 'When you have new updates, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _brown.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.6,
              ),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () {
                  setState(() => _selectedFilter = 'All');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _darkBrown,
                  side: const BorderSide(color: _gold),
                ),
                child: const Text('View all notifications'),
              ),
            ],
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(
                foregroundColor: _darkBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
