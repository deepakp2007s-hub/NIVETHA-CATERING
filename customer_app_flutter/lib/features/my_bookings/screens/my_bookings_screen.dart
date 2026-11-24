import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/services/booking_service.dart';

/// My Bookings screen displaying order history, status updates, and cancellation controls
/// styled in the Forest Emerald & Warm Champagne Gold theme.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  // Forest Emerald & Warm Champagne Gold Palette
  static const Color _forestEmerald = Color(0xFF144536);
  static const Color _deepForest = Color(0xFF0C2E24);
  static const Color _champagneGold = Color(0xFFD9A441);
  static const Color _softIvory = Color(0xFFFBF9F5);
  static const Color _warmSandBorder = Color(0xFFE5DEC9);
  static const Color _inkDark = Color(0xFF1A2421);
  static const Color _inkMuted = Color(0xFF5A6863);
  static const Color _warmAmber = Color(0xFFB46916);

  final BookingService _bookingService = BookingService();
  late Future<List<BookingModel>> _bookingsFuture;
  String _selectedStatusFilter = 'All';

  final List<String> _statusFilters = [
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

  void _loadBookings() {
    _bookingsFuture = _bookingService.getMyBookings(page: 1, limit: 50);
  }

  Future<void> _openCreateBooking() async {
    await Navigator.pushNamed(context, '/create-booking');
    if (mounted) {
      setState(() {
        _loadBookings();
      });
    }
  }

  Future<void> _handleCancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: _warmSandBorder),
        ),
        title: const Text(
          'Cancel Catering Request?',
          style: TextStyle(fontWeight: FontWeight.w800, color: _inkDark),
        ),
        content: const Text(
          'Are you sure you want to cancel this catering booking request? This action cannot be undone.',
          style: TextStyle(color: _inkMuted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Keep Booking',
              style: TextStyle(color: _forestEmerald, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _bookingService.cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking request cancelled.'),
            backgroundColor: _warmAmber,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _loadBookings();
        });
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showBookingDetailsSheet(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.88,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _warmSandBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.functionType,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: _inkDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: booking.statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: booking.statusColor),
                        ),
                        child: Text(
                          booking.formattedStatus,
                          style: TextStyle(
                            color: booking.statusColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: _warmSandBorder),
                  _buildDetailItem(
                    Icons.calendar_month_rounded,
                    'Date & Time',
                    '${booking.formattedDate} at ${booking.eventTime}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    Icons.people_outline_rounded,
                    'Guest Capacity',
                    '${booking.personsCount} Guests (${booking.mealType} - ${booking.foodPreference})',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    Icons.location_on_outlined,
                    'Venue Address',
                    booking.location,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailItem(
                    Icons.room_service_outlined,
                    'Service Requirements',
                    [
                      if (booking.cateringServiceRequired) 'Vessels & Setup',
                      if (booking.cookingService) 'Live Cooking',
                      if (booking.servingStaffRequired) 'Serving Staff',
                    ].join(' • '),
                  ),
                  if (booking.specialRequirements != null &&
                      booking.specialRequirements!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      Icons.notes_rounded,
                      'Special Instructions',
                      booking.specialRequirements!,
                    ),
                  ],
                  if (booking.ownerNote != null &&
                      booking.ownerNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailItem(
                      Icons.rate_review_rounded,
                      'Caterer Note',
                      booking.ownerNote!,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (booking.selectedFoods.isNotEmpty) ...[
                    const Text(
                      'Selected Menu Items',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _inkDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: booking.selectedFoods.map((item) {
                        return Chip(
                          label: Text(
                            item.foodName,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: _inkDark,
                            ),
                          ),
                          backgroundColor: _softIvory,
                          side: const BorderSide(color: _warmSandBorder),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (booking.status.toLowerCase() == 'pending' &&
                      booking.id.isNotEmpty) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFC62828),
                          side: const BorderSide(color: Color(0xFFC62828)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _handleCancelBooking(booking.id);
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text(
                          'Cancel Booking Request',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _forestEmerald.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _forestEmerald),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: _inkMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Standard Catering',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _inkDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softIvory,
      appBar: AppBar(
        backgroundColor: _forestEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Catering Bookings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: _champagneGold),
            onPressed: () {
              setState(() {
                _loadBookings();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: _warmSandBorder, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusFilters.map((filter) {
                  final isSelected = _selectedStatusFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedStatusFilter = filter);
                      },
                      selectedColor: _forestEmerald,
                      backgroundColor: _softIvory,
                      checkmarkColor: _champagneGold,
                      side: BorderSide(
                        color: isSelected ? _forestEmerald : _warmSandBorder,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : _inkDark,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: _forestEmerald,
              backgroundColor: Colors.white,
              onRefresh: () async {
                setState(() {
                  _loadBookings();
                });
                try {
                  await _bookingsFuture;
                } catch (_) {}
              },
              child: FutureBuilder<List<BookingModel>>(
                future: _bookingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _forestEmerald),
                    );
                  }

                  if (snapshot.hasError) {
                    final errorMsg = snapshot.error
                        .toString()
                        .replaceAll('Exception: ', '');
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24.0),
                      children: [
                        const SizedBox(height: 80),
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Color(0xFFC62828),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load bookings.\n$errorMsg',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFC62828)),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forestEmerald,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => setState(() => _loadBookings()),
                            child: const Text('Retry'),
                          ),
                        ),
                      ],
                    );
                  }

                  final allBookings = snapshot.data ?? [];
                  final filteredBookings = allBookings.where((b) {
                    if (_selectedStatusFilter == 'All') return true;
                    return b.status.toLowerCase() ==
                        _selectedStatusFilter.toLowerCase();
                  }).toList();

                  if (filteredBookings.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(32.0),
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _forestEmerald.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _champagneGold.withValues(alpha: 0.6),
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_today_rounded,
                              size: 44,
                              color: _forestEmerald,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Bookings Found',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _inkDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedStatusFilter == 'All'
                              ? 'You have not submitted any event catering requests yet.'
                              : 'No bookings matching "$_selectedStatusFilter" status.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _inkMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _forestEmerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _openCreateBooking,
                            icon: const Icon(
                              Icons.add_rounded,
                              color: _champagneGold,
                            ),
                            label: const Text(
                              'Book Event Catering Now',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                    itemCount: filteredBookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final item = filteredBookings[index];
                      return _buildBookingCard(context, item);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: _forestEmerald,
        foregroundColor: Colors.white,
        onPressed: _openCreateBooking,
        icon: const Icon(Icons.add_rounded, color: _champagneGold),
        label: const Text(
          'New Booking',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _warmSandBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: _deepForest.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showBookingDetailsSheet(item),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _forestEmerald.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.celebration_rounded,
                            color: _forestEmerald,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.functionType,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _inkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: item.statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: item.statusColor.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      item.formattedStatus,
                      style: TextStyle(
                        color: item.statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: _warmSandBorder),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 15,
                    color: _forestEmerald,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${item.formattedDate} • ${item.eventTime}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: _inkDark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.people_outline_rounded,
                    size: 16,
                    color: _warmAmber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.personsCount} Guests',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: _inkDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: _inkMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _inkMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${item.selectedFoods.length} Dishes Selected • ${item.mealType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _warmAmber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'View Details ›',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _forestEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}