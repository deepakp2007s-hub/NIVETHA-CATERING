import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookingService = BookingService();
  late Future<List<BookingModel>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    _bookingsFuture = _bookingService.getMyBookings();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  Future<void> _handleCancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this catering booking request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
            content: Text('Booking cancelled successfully.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _loadBookings();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Bookings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadBookings();
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadBookings();
          });
        },
        child: FutureBuilder<List<BookingModel>>(
          future: _bookingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to fetch bookings\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadBookings();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final bookings = snapshot.data ?? [];

            if (bookings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Bookings Found',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You haven\'t requested any catering events yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create-booking').then((_) {
                            setState(() {
                              _loadBookings();
                            });
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Book Event Now'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final statusColor = _getStatusColor(booking.status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              booking.eventType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                booking.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.calendar_month, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "${booking.eventDate.day}/${booking.eventDate.month}/${booking.eventDate.year}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 24),
                            const Icon(Icons.people_outline, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text('${booking.guestCount} Guests'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                booking.venueAddress,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (booking.selectedFoodIds.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.restaurant_menu, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                '${booking.selectedFoodIds.length} Selected Dishes',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (booking.status.toLowerCase() == 'pending') ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: () {
                                if (booking.id.isNotEmpty) {
                                  _handleCancelBooking(booking.id);
                                }
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 18),
                              label: const Text('Cancel Request'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}