
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../main_shell_screen.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
  });

  String _read(
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

  @override
  Widget build(BuildContext context) {
    final bookingId = _read(
      ['bookingId', 'bookingNumber', '_id', 'id'],
      fallback: 'Pending assignment',
    );

    final status = _read(
      ['status'],
      fallback: 'Pending',
    );

    final event = _read(
      ['customerType', 'eventType', 'functionType'],
      fallback: 'Catering Event',
    );

    final rawDate = _read(
      ['functionDate', 'eventDate', 'date'],
    );

    final time = _read(
      ['functionTime', 'eventTime', 'time'],
    );

    final location = _read(
      ['location', 'eventLocation'],
    );

    final persons = _read(
      ['numberOfPersons', 'persons', 'guestCount'],
    );

    final foodPreference = _read(
      ['foodPreference', 'foodType'],
    );

    final mealsValue = booking['meals'] ?? booking['selectedMeals'];
    final meals = mealsValue is List
        ? mealsValue.map((item) => item.toString()).join(', ')
        : (mealsValue?.toString() ?? 'Not provided');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Booking Confirmation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.primaryGreenLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 70,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Booking Request Submitted!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryGreenDark,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'உங்கள் முன்பதிவு கோரிக்கை பெறப்பட்டது.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          Container(
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
            child: Column(
              children: [
                const Text(
                  'BOOKING REFERENCE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  bookingId,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.goldAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Event Summary',
            style: TextStyle(
              color: AppColors.primaryGreenDark,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _detail(Icons.event_rounded, 'Event', event),
                _divider(),
                _detail(
                  Icons.calendar_month_rounded,
                  'Date',
                  rawDate == 'Not provided'
                      ? rawDate
                      : _formatDate(rawDate),
                ),
                _divider(),
                _detail(Icons.access_time_rounded, 'Time', time),
                _divider(),
                _detail(
                  Icons.location_on_outlined,
                  'Location',
                  location,
                ),
                _divider(),
                _detail(
                  Icons.groups_rounded,
                  'Persons',
                  persons,
                ),
                _divider(),
                _detail(
                  Icons.restaurant_menu_rounded,
                  'Food Preference',
                  foodPreference,
                ),
                _divider(),
                _detail(
                  Icons.lunch_dining_rounded,
                  'Selected Meals',
                  meals,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.surfaceCream,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.goldAccent.withValues(alpha: 0.6),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.goldDark,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your request is subject to confirmation by '
                    'Nivetha Catering Service. Please keep your '
                    'booking reference for future enquiries.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const MainShellScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'BACK TO HOME',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const MainShellScreen(),
                  ),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'VIEW MY BOOKINGS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 24,
      color: AppColors.divider,
    );
  }

  Widget _detail(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
