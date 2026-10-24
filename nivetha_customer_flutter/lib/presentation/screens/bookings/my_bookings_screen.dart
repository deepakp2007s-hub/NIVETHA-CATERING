
import 'package:flutter/material.dart';

import '../../../core/services/booking_service.dart';
import '../../../data/models/booking_model.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  bool _isLoading = true;
  String? _error;
  List<BookingModel> _bookings = [];
  String _selectedFilter = 'All';

  final List<String> _filters = const [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
    'Rejected',
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

    _loadBookings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await BookingService.instance.getMyBookings();

      if (!mounted) return;

      final List<BookingModel> bookings = result
          .map<BookingModel>(
            (item) => BookingModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      setState(() {
        _bookings = bookings;
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

  String _normalizeStatus(String? status) {
    final value = (status ?? '').trim().toLowerCase();

    if (value == 'cancel' || value == 'canceled') {
      return 'cancelled';
    }

    if (value == 'approved') return 'confirmed';
    if (value == 'complete') return 'completed';

    return value;
  }

  List<BookingModel> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;

    return _bookings.where((booking) {
      return _normalizeStatus(booking.status) ==
          _selectedFilter.toLowerCase();
    }).toList();
  }

  int _countStatus(String status) {
    return _bookings
        .where((booking) => _normalizeStatus(booking.status) == status)
        .length;
  }

  Color _statusColor(String? status) {
    switch (_normalizeStatus(status)) {
      case 'confirmed':
        return const Color(0xFF21865B);
      case 'completed':
        return const Color(0xFF326BC1);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFC54646);
      case 'pending':
        return const Color(0xFFB27A17);
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String? status) {
    switch (_normalizeStatus(status)) {
      case 'confirmed':
        return Icons.verified_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date not provided';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatAmount(num? value) {
    return '₹${(value ?? 0).toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBookings;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: RefreshIndicator(
          color: gold,
          onRefresh: _loadBookings,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                  child: _buildHeader(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSummary(),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 22),
              ),
              SliverToBoxAdapter(
                child: _buildFilters(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your Events',
                          style: TextStyle(
                            color: navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '${filtered.length} booking${filtered.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildBookingCard(filtered[index]),
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
                color: navy.withValues(alpha: 0.17),
                blurRadius: 13,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.calendar_month_rounded,
            color: gold,
            size: 28,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Bookings',
                style: TextStyle(
                  color: navy,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'என் முன்பதிவுகள்',
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
          onPressed: _loadBookings,
          tooltip: 'Refresh bookings',
          icon: const Icon(Icons.refresh_rounded, color: navy),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [navy, Color(0xFF294D70)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
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
          Expanded(
            child: _summaryItem(
              'Total',
              _bookings.length,
              Icons.receipt_long_rounded,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              'Pending',
              _countStatus('pending'),
              Icons.hourglass_top_rounded,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              'Confirmed',
              _countStatus('confirmed'),
              Icons.verified_rounded,
            ),
          ),
          _summaryDivider(),
          Expanded(
            child: _summaryItem(
              'Completed',
              _countStatus('completed'),
              Icons.task_alt_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 21),
        const SizedBox(height: 9),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(
      width: 1,
      height: 58,
      color: Colors.white.withValues(alpha: 0.17),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter;

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 17),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? navy : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: selected ? navy : const Color(0xFFE7DDCE),
                ),
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

  Widget _buildBookingCard(BookingModel booking) {
    final statusColor = _statusColor(booking.status);
    final rawStatus = booking.status.trim();
    final status = rawStatus.isEmpty
        ? 'Unknown'
        : '${rawStatus[0].toUpperCase()}${rawStatus.substring(1)}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingDetailsScreen(booking: booking),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFECE3D5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.celebration_rounded,
                      color: navy,
                      size: 25,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.eventType,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'ID: ${booking.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.blueGrey.shade500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _statusIcon(booking.status),
                            size: 13,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              status,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const Divider(height: 1, color: Color(0xFFF0E8DC)),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _bookingInfo(
                      Icons.calendar_month_rounded,
                      'Date',
                      _formatDate(booking.eventDate),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _bookingInfo(
                      Icons.groups_rounded,
                      'Persons',
                      '${booking.numberOfPersons}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: Colors.blueGrey.shade400,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      booking.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blueGrey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: gold,
                    size: 14,
                  ),
                ],
              ),
              if (booking.totalAmount > 0) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      'Estimated Total',
                      style: TextStyle(
                        color: Colors.blueGrey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatAmount(booking.totalAmount),
                      style: const TextStyle(
                        color: navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _bookingInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: gold, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
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
                Icons.event_note_rounded,
                size: 51,
                color: navy,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'No Bookings Found',
              style: TextStyle(
                color: navy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              _selectedFilter == 'All'
                  ? 'You have not made any bookings yet.'
                  : 'No ${_selectedFilter.toLowerCase()} bookings found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedFilter = 'All'),
              child: const Text('Show All Bookings'),
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
              size: 60,
              color: Color(0xFFC54646),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to Load Bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: navy,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadBookings,
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
