
import 'package:flutter/material.dart';

import '../bookings/my_bookings_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingConfirmationScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);
  static const Color success = Color(0xFF26845B);

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _value(String key, {String fallback = '-'}) {
    final value = widget.bookingData[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  String _formatDate(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final eventDate = _value('eventDate');
    final bookingNumber = widget.bookingId.trim().isEmpty
        ? 'Pending server confirmation'
        : widget.bookingId;

    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 10),

                      // Animated success icon
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Center(
                          child: Container(
                            width: 126,
                            height: 126,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFBCEBD2),
                                  Color(0xFF65C797),
                                  Color(0xFF26845B),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: success.withValues(alpha: 0.23),
                                  blurRadius: 28,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 76,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Booking Submitted!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: navy,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'உங்கள் முன்பதிவு விவரங்கள் அனுப்பப்பட்டுள்ளன.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 26),

                      _buildBookingIdCard(bookingNumber),

                      const SizedBox(height: 25),

                      const Text(
                        'Event Summary',
                        style: TextStyle(
                          color: navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'உங்கள் விழா விவரங்கள்',
                        style: TextStyle(
                          color: Color(0xFF987022),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 15),

                      _buildDetailsCard(
                        details: [
                          _DetailItem(
                            icon: Icons.celebration_rounded,
                            label: 'Event Type',
                            value: _value('eventType'),
                          ),
                          _DetailItem(
                            icon: Icons.calendar_month_rounded,
                            label: 'Function Date',
                            value: eventDate == '-'
                                ? '-'
                                : _formatDate(eventDate),
                          ),
                          _DetailItem(
                            icon: Icons.access_time_rounded,
                            label: 'Function Time',
                            value: _value('eventTime'),
                          ),
                          _DetailItem(
                            icon: Icons.location_on_rounded,
                            label: 'Location',
                            value: _value('location'),
                          ),
                          _DetailItem(
                            icon: Icons.groups_rounded,
                            label: 'Number of Persons',
                            value: _value('numberOfPersons'),
                          ),
                          _DetailItem(
                            icon: Icons.restaurant_menu_rounded,
                            label: 'Catering Service',
                            value: _value('cateringType'),
                          ),
                          _DetailItem(
                            icon: Icons.dinner_dining_rounded,
                            label: 'Meal Session',
                            value: _value('mealType'),
                          ),
                          _DetailItem(
                            icon: Icons.restaurant_rounded,
                            label: 'Food Preference',
                            value: _value('foodType'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 19),

                      _buildStatusCard(),

                      const SizedBox(height: 27),

                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const MyBookingsScreen(),
                              ),
                              (route) => route.isFirst,
                            );
                          },
                          icon: const Icon(
                            Icons.receipt_long_rounded,
                          ),
                          label: const Text(
                            'View My Bookings',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: navy,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: navy.withValues(alpha: 0.20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 13),

                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil(
                            (route) => route.isFirst,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: navy,
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(
                            color: Color(0xFFD9A441),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Text(
                        'Thank you for choosing Nivetha Catering Service!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingIdCard(String bookingNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF25496C),
            navy,
            Color(0xFF091629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.confirmation_number_rounded,
            color: gold,
            size: 35,
          ),
          const SizedBox(height: 12),
          Text(
            'YOUR BOOKING ID',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 9),
          SelectableText(
            bookingNumber,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE6A2),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Please keep this ID for reference.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard({
    required List<_DetailItem> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
      ),
      child: Column(
        children: [
          for (int index = 0; index < details.length; index++) ...[
            _detailRow(details[index]),
            if (index != details.length - 1)
              const Divider(
                height: 24,
                color: Color(0xFFF0E8DC),
              ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(_DetailItem detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            detail.icon,
            color: navy,
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail.value,
                style: const TextStyle(
                  color: navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFCB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gold.withValues(alpha: 0.40),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF89621D),
            size: 25,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awaiting Confirmation',
                  style: TextStyle(
                    color: navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Your request has been submitted. The catering team must confirm your booking before it is finalized.',
                  style: TextStyle(
                    color: Color(0xFF655431),
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

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}
