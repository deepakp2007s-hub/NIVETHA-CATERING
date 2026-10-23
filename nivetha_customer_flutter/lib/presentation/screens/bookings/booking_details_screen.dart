
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  String _value(
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
      return DateFormat('dd MMMM yyyy').format(DateTime.parse(value));
    } catch (_) {
      return value;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'completed':
        return AppColors.info;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      case 'pending':
      default:
        return AppColors.warning;
    }
  }

  List<String> _readMeals() {
    final value = booking['meals'] ?? booking['selectedMeals'];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value.split(',').map((item) => item.trim()).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final bookingId = _value(
      ['bookingId', 'bookingNumber', '_id', 'id'],
      fallback: 'Not assigned',
    );

    final event = _value(
      ['customerType', 'eventType', 'functionType'],
      fallback: 'Catering Event',
    );

    final status = _value(['status'], fallback: 'Pending');

    final date = _value(
      ['functionDate', 'eventDate', 'date'],
    );

    final time = _value(
      ['functionTime', 'eventTime', 'time'],
    );

    final location = _value(
      ['location', 'eventLocation', 'address'],
    );

    final persons = _value(
      ['numberOfPersons', 'persons', 'guestCount'],
    );

    final foodPreference = _value(
      ['foodPreference', 'foodType'],
    );

    final cookingService = booking['cookingService'];
    final servingStaff = booking['servingStaff'];

    final meals = _readMeals();
    final color = _statusColor(status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryGreenDark,
                  AppColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.event_available_rounded,
                  color: AppColors.goldAccent,
                  size: 38,
                ),
                const SizedBox(height: 14),
                Text(
                  event,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking ID: $bookingId',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: color == AppColors.warning
                          ? AppColors.goldAccent
                          : Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _sectionTitle('Event Information'),
          const SizedBox(height: 12),
          _detailsCard([
            _detailRow(
              Icons.calendar_month_rounded,
              'Function Date',
              date == 'Not provided' ? date : _formatDate(date),
            ),
            _detailRow(
              Icons.access_time_rounded,
              'Function Time',
              time,
            ),
            _detailRow(
              Icons.location_on_rounded,
              'Event Location',
              location,
            ),
            _detailRow(
              Icons.groups_rounded,
              'Number of Persons',
              persons,
            ),
          ]),
          const SizedBox(height: 22),
          _sectionTitle('Food Preferences'),
          const SizedBox(height: 12),
          _detailsCard([
            _detailRow(
              Icons.restaurant_menu_rounded,
              'Food Type',
              foodPreference,
            ),
            if (meals.isNotEmpty)
              _detailRow(
                Icons.lunch_dining_rounded,
                'Selected Meals',
                meals.join(', '),
              ),
          ]),
          const SizedBox(height: 22),
          _sectionTitle('Additional Services'),
          const SizedBox(height: 12),
          _detailsCard([
            _detailRow(
              Icons.soup_kitchen_rounded,
              'Cooking Service',
              _yesNo(cookingService),
            ),
            _detailRow(
              Icons.people_alt_rounded,
              'Serving Staff',
              _yesNo(servingStaff),
            ),
          ]),
          const SizedBox(height: 22),
          _sectionTitle('Additional Requirements'),
          const SizedBox(height: 12),
          _detailsCard([
            _detailRow(
              Icons.notes_rounded,
              'Requirements',
              _value(
                ['extraRequirements', 'requirements', 'notes'],
                fallback: 'No additional requirements',
              ),
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to My Bookings'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _yesNo(dynamic value) {
    if (value == true) return 'Required';
    if (value == false) return 'Not required';

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return 'Not provided';
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w900,
        color: AppColors.primaryGreenDark,
      ),
    );
  }

  Widget _detailsCard(List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 22,
                color: AppColors.divider,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryGreenLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
