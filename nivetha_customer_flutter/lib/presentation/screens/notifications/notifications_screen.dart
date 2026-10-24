
import 'package:flutter/material.dart';

import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _notifications = [];
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Unread',
    'Read',
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _loadNotifications();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dynamic response =
          await NotificationService.instance.getNotifications();

      final dynamic rawList = response is List
          ? response
          : response is Map
              ? response['notifications'] ??
                  response['data'] ??
                  response['results'] ??
                  []
              : [];

      final items = <Map<String, dynamic>>[];

      if (rawList is List) {
        for (final item in rawList) {
          if (item is Map) {
            items.add(Map<String, dynamic>.from(item));
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _notifications = items;
        _isLoading = false;
      });

      _controller.forward(from: 0);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  bool _isRead(Map<String, dynamic> notification) {
    final value = notification['isRead'] ??
        notification['read'] ??
        notification['seen'] ??
        false;

    if (value is bool) return value;

    return value.toString().toLowerCase() == 'true';
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications.where((item) => !_isRead(item)).toList();
      case 'Read':
        return _notifications.where(_isRead).toList();
      default:
        return _notifications;
    }
  }

  int get _unreadCount =>
      _notifications.where((item) => !_isRead(item)).length;

  String _title(Map<String, dynamic> notification) {
    return (notification['title'] ??
            notification['heading'] ??
            notification['subject'] ??
            'Nivetha Catering')
        .toString();
  }

  String _message(Map<String, dynamic> notification) {
    return (notification['message'] ??
            notification['body'] ??
            notification['description'] ??
            'You have a new notification.')
        .toString();
  }

  String _type(Map<String, dynamic> notification) {
    return (notification['type'] ??
            notification['category'] ??
            'general')
        .toString()
        .toLowerCase();
  }

  String _date(Map<String, dynamic> notification) {
    final raw = notification['createdAt'] ??
        notification['created_at'] ??
        notification['date'];

    if (raw == null) return '';

    final date = DateTime.tryParse(raw.toString());

    if (date == null) return raw.toString();

    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year}  '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  String _notificationId(Map<String, dynamic> notification) {
    return (notification['_id'] ??
            notification['id'] ??
            notification['notificationId'] ??
            '')
        .toString();
  }

  IconData _iconForType(String type) {
    if (type.contains('confirm')) {
      return Icons.verified_rounded;
    }
    if (type.contains('cancel') || type.contains('reject')) {
      return Icons.cancel_rounded;
    }
    if (type.contains('payment')) {
      return Icons.account_balance_wallet_rounded;
    }
    if (type.contains('reminder')) {
      return Icons.alarm_rounded;
    }
    if (type.contains('complete')) {
      return Icons.task_alt_rounded;
    }
    if (type.contains('booking')) {
      return Icons.event_available_rounded;
    }

    return Icons.notifications_active_rounded;
  }

  Color _colorForType(String type) {
    if (type.contains('confirm') || type.contains('complete')) {
      return const Color(0xFF21865B);
    }
    if (type.contains('cancel') || type.contains('reject')) {
      return const Color(0xFFC54646);
    }
    if (type.contains('payment')) {
      return const Color(0xFF326BC1);
    }
    if (type.contains('reminder')) {
      return const Color(0xFFB27A17);
    }

    return navy;
  }

  Future<void> _markRead(Map<String, dynamic> notification) async {
    if (_isRead(notification)) return;

    final id = _notificationId(notification);

    if (id.isEmpty) {
      _showMessage('Notification ID is missing.');
      return;
    }

    try {
      await NotificationService.instance.markAsRead(id);

      if (!mounted) return;

      setState(() {
        notification['isRead'] = true;
        notification['read'] = true;
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage('Unable to mark as read. Please try again.');
    }
  }

  Future<void> _markAllRead() async {
    final unread = _notifications.where((item) => !_isRead(item)).toList();

    if (unread.isEmpty) {
      _showMessage('All notifications are already read.');
      return;
    }

    try {
      for (final notification in unread) {
        final id = _notificationId(notification);

        if (id.isNotEmpty) {
          await NotificationService.instance.markAsRead(id);
        }
      }

      if (!mounted) return;

      setState(() {
        for (final notification in _notifications) {
          notification['isRead'] = true;
          notification['read'] = true;
        }
      });

      _showMessage('All notifications marked as read.');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Some notifications could not be updated. Refresh and try again.',
      );

      await _loadNotifications();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navy,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredNotifications;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          onRefresh: _loadNotifications,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 23, 20, 18),
                  child: _buildHeader(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildHeroCard(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (_unreadCount > 0)
                        TextButton(
                          onPressed: _markAllRead,
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Color(0xFF987022),
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildFilters(),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: gold),
                  ),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildError(),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmpty(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 17, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final notification = filtered[index];

                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationCard(notification),
                          ),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [navy, Color(0xFF345779)],
            ),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: navy.withValues(alpha: 0.16),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: gold,
            size: 27,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: TextStyle(
                  color: navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'அறிவிப்புகள்',
                style: TextStyle(
                  color: Color(0xFF987022),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh notifications',
          onPressed: _loadNotifications,
          icon: const Icon(
            Icons.refresh_rounded,
            color: navy,
            size: 26,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF294D70),
            navy,
            Color(0xFF091629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: gold.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: gold,
              size: 31,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay Updated!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _unreadCount == 0
                      ? 'You are all caught up.'
                      : 'You have $_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '$_unreadCount',
              style: const TextStyle(
                color: navy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = filter);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? navy : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? navy
                      : const Color(0xFFE7DDCE),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: navy.withValues(alpha: 0.13),
                          blurRadius: 9,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected ? gold : navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
  ) {
    final read = _isRead(notification);
    final type = _type(notification);
    final color = _colorForType(type);
    final date = _date(notification);

    return Material(
      color: read ? Colors.white : const Color(0xFFFFFDF7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _markRead(notification),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: read
                  ? const Color(0xFFECE3D5)
                  : gold.withValues(alpha: 0.65),
            ),
            boxShadow: read
                ? []
                : [
                    BoxShadow(
                      color: gold.withValues(alpha: 0.08),
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _iconForType(type),
                  color: color,
                  size: 25,
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
                            _title(notification),
                            style: TextStyle(
                              color: navy,
                              fontSize: 14,
                              fontWeight:
                                  read ? FontWeight.w700 : FontWeight.w900,
                            ),
                          ),
                        ),
                        if (!read) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      _message(notification),
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                        height: 1.55,
                      ),
                    ),
                    if (date.isNotEmpty) ...[
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: Colors.blueGrey.shade400,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              date,
                              style: TextStyle(
                                color: Colors.blueGrey.shade500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Text(
                            read ? 'Read' : 'Unread',
                            style: TextStyle(
                              color: read
                                  ? Colors.blueGrey.shade400
                                  : const Color(0xFF987022),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_rounded,
                color: navy,
                size: 49,
              ),
            ),
            const SizedBox(height: 21),
            const Text(
              'No Notifications',
              style: TextStyle(
                color: navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              _selectedFilter == 'All'
                  ? 'You will see booking updates and reminders here.'
                  : 'No ${_selectedFilter.toLowerCase()} notifications found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                setState(() => _selectedFilter = 'All');
              },
              child: const Text('Show All'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFC54646),
              size: 58,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
