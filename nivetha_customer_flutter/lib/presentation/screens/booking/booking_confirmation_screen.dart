
import 'package:flutter/material.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final String bookingId;
  final String eventType;
  final DateTime? eventDate;
  final String eventTime;
  final String location;
  final int persons;
  final String foodType;
  final String mealType;

  const BookingConfirmationScreen({
    super.key,
    this.bookingId = '',
    this.eventType = '',
    this.eventDate,
    this.eventTime = '',
    this.location = '',
    this.persons = 0,
    this.foodType = '',
    this.mealType = '',
  });

  static const Color _cream = Color(0xFFFFF9F0);
  static const Color _darkBrown = Color(0xFF3E2723);
  static const Color _brown = Color(0xFF795548);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _lightGold = Color(0xFFFFF0C2);
  static const Color _muted = Color(0xFF82736A);

  String get _displayBookingId {
    final id = bookingId.trim();
    return id.isEmpty ? 'Pending Confirmation' : id;
  }

  String get _displayDate {
    if (eventDate == null) return 'Not specified';

    final date = eventDate!;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _display(String value) {
    return value.trim().isEmpty ? 'Not specified' : value.trim();
  }

  String get _displayPersons {
    return persons > 0 ? '$persons persons' : 'Not specified';
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 52,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    _buildSuccessIcon(),
                    const SizedBox(height: 24),
                    const Text(
                      'Booking Request\nSubmitted!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _darkBrown,
                        fontSize: 29,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Thank you for choosing Nivetha Catering Service.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _buildBookingReference(),
                    const SizedBox(height: 22),
                    _buildEventSummary(),
                    const SizedBox(height: 20),
                    _buildPendingNotice(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => _goHome(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkBrown,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home_rounded, size: 21),
                            SizedBox(width: 10),
                            Text(
                              'Back to Home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Navigator.maybePop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _darkBrown,
                          side: const BorderSide(
                            color: _gold,
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: _lightGold,
        shape: BoxShape.circle,
        border: Border.all(
          color: _gold.withValues(alpha: 0.65),
          width: 2,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: _gold,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 55,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBookingReference() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _gold.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: _gold,
            size: 30,
          ),
          const SizedBox(height: 10),
          const Text(
            'YOUR BOOKING REFERENCE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 11,
              letterSpacing: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          SelectableText(
            _displayBookingId,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _darkBrown,
              fontSize: bookingId.length > 22 ? 15 : 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep this reference for future enquiries.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                color: _gold,
                size: 23,
              ),
              SizedBox(width: 10),
              Text(
                'Event Summary',
                style: TextStyle(
                  color: _darkBrown,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _summaryRow(
            icon: Icons.celebration_outlined,
            label: 'Event Type',
            value: _display(eventType),
          ),
          _summaryDivider(),
          _summaryRow(
            icon: Icons.calendar_month_outlined,
            label: 'Event Date',
            value: _displayDate,
          ),
          _summaryDivider(),
          _summaryRow(
            icon: Icons.access_time_rounded,
            label: 'Event Time',
            value: _display(eventTime),
          ),
          _summaryDivider(),
          _summaryRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: _display(location),
          ),
          _summaryDivider(),
          _summaryRow(
            icon: Icons.people_outline_rounded,
            label: 'Guests',
            value: _displayPersons,
          ),
          if (foodType.trim().isNotEmpty) ...[
            _summaryDivider(),
            _summaryRow(
              icon: Icons.restaurant_menu_rounded,
              label: 'Food Preference',
              value: foodType,
            ),
          ],
          if (mealType.trim().isNotEmpty) ...[
            _summaryDivider(),
            _summaryRow(
              icon: Icons.dinner_dining_rounded,
              label: 'Meal Type',
              value: mealType,
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Divider(
        height: 1,
        thickness: 1,
        color: _darkBrown.withValues(alpha: 0.07),
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _lightGold.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: _brown,
            size: 20,
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
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _darkBrown,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingNotice() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8C98B),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _brown,
            size: 23,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awaiting Confirmation',
                  style: TextStyle(
                    color: _darkBrown,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your booking request has been submitted. '
                  'The catering team must review and approve it '
                  'before it becomes a confirmed booking.',
                  style: TextStyle(
                    color: _brown,
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
