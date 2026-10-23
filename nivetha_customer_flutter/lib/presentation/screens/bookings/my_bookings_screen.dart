
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/booking_service.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final String? token;

  const MyBookingsScreen({
    super.key,
    this.token,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _bookings = [];
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
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final token = widget.token;

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;

      setState(() {
        _error = 'Please sign in to view your bookings.';
        _isLoading = false;
        _bookings = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await BookingService.instance.getMyBookings(
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _bookings = result;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'Unable to load bookings. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _read(
    Map<String, dynamic> booking,
    List<String> keys, {
    String fallback = 'Not provided',
  }) {
    for (final key in keys) {
      final value = booking[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }

  String _formatDate(String value) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') return _bookings;

    return _bookings.where((booking) {
      final status = _read(
        booking,
        ['status'],
        fallback: 'Pending',
      );

      return status.toLowerCase() ==
          _selectedFilter.toLowerCase();
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        actions: [
          IconButton(
            onPressed: _loadBookings,
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
            child: const Row(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  color: AppColors.goldAccent,
                  size: 38,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Events',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'உங்கள் நிகழ்ச்சி முன்பதிவுகள்',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = filter == _selectedFilter;

                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                  },
                );
              },
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(
        message: 'Loading your bookings...',
      );
    }

    if (_error != null) {
      return ErrorStateWidget(
        title: 'Bookings Unavailable',
        message: _error!,
        onRetry: _loadBookings,
      );
    }

    final bookings = _filteredBookings;

    if (bookings.isEmpty) {
      return EmptyStateWidget(
        title: _selectedFilter == 'All'
            ? 'No Bookings Yet'
            : 'No $_selectedFilter Bookings',
        message: _selectedFilter == 'All'
            ? 'Your catering bookings will appear here.'
            : 'Try another status filter to view your bookings.',
        icon: Icons.event_busy_rounded,
        buttonText: _selectedFilter == 'All'
            ? 'Refresh'
            : 'Show All',
        onButtonPressed: () {
          if (_selectedFilter != 'All') {
            setState(() => _selectedFilter = 'All');
          } else {
            _loadBookings();
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: bookings.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final booking = bookings[index];

          final id = _read(
            booking,
            ['bookingId', 'bookingNumber', '_id', 'id'],
            fallback: 'Not assigned',
          );

          final event = _read(
            booking,
            ['customerType', 'eventType', 'functionType'],
            fallback: 'Catering Event',
          );

          final rawDate = _read(
            booking,
            ['functionDate', 'eventDate', 'date'],
          );

          final status = _read(
            booking,
            ['status'],
            fallback: 'Pending',
          );

          final persons = _read(
            booking,
            ['numberOfPersons', 'persons', 'guestCount'],
          );

          final location = _read(
            booking,
            ['location', 'eventLocation'],
          );

          return _bookingCard(
            booking: booking,
            id: id,
            event: event,
            date: _formatDate(rawDate),
            status: status,
            persons: persons,
            location: location,
          );
        },
      ),
    );
  }

  Widget _bookingCard({
    required Map<String, dynamic> booking,
    required String id,
    required String event,
    required String date,
    required String status,
    required String persons,
    required String location,
  }) {
    final color = _statusColor(status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BookingDetailsScreen(
                booking: booking,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event,
                      style: const TextStyle(
                        color: AppColors.primaryGreenDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                'Booking ID: $id',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              _infoRow(Icons.calendar_month_rounded, date),
              const SizedBox(height: 10),
              _infoRow(Icons.groups_rounded, '$persons persons'),
              const SizedBox(height: 10),
              _infoRow(Icons.location_on_outlined, location),
              const SizedBox(height: 14),
              const Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
