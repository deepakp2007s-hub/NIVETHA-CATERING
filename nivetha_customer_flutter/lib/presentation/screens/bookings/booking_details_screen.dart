
import 'package:flutter/material.dart';

import '../../../data/models/booking_model.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brown = Color(0xFF402719);
  static const Color _darkBrown = Color(0xFF2E1B12);
  static const Color _gold = Color(0xFFD5A64A);
  static const Color _cream = Color(0xFFFFF8ED);
  static const Color _lightGold = Color(0xFFF5E5C2);
  static const Color _muted = Color(0xFF786B60);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not provided';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatMoney(num amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _display(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not provided';
    }

    return value.trim();
  }

  String _normalizedStatus(String? value) {
    final status = (value ?? 'pending').trim().toLowerCase();

    switch (status) {
      case 'approved':
        return 'confirmed';
      case 'cancel':
      case 'canceled':
        return 'cancelled';
      case 'complete':
        return 'completed';
      default:
        return status.isEmpty ? 'pending' : status;
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return 'Unknown';

    return value
        .split(RegExp(r'\s+'))
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  Color _statusColor(String status) {
    switch (_normalizedStatus(status)) {
      case 'confirmed':
        return const Color(0xFF21865B);
      case 'completed':
        return const Color(0xFF326BC1);
      case 'pending':
        return const Color(0xFFB27A17);
      case 'cancelled':
      case 'rejected':
        return const Color(0xFFC54646);
      default:
        return Colors.blueGrey;
    }
  }

  IconData _statusIcon(String status) {
    switch (_normalizedStatus(status)) {
      case 'confirmed':
        return Icons.verified_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      case 'pending':
        return Icons.hourglass_top_rounded;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    final normalizedStatus = _normalizedStatus(booking.status);
    final status = _capitalize(normalizedStatus);
    final statusColor = _statusColor(booking.status);
    final notes = _display(
      booking.extraRequirements ?? booking.notes,
    );

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _cream,
        foregroundColor: _brown,
        elevation: 0,
        title: const Text(
          'Booking Details',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                _buildHeroCard(
                  booking.bookingId.trim().isNotEmpty
                      ? booking.bookingId
                      : booking.id,
                  status,
                  statusColor,
                  booking.status,
                ),
                const SizedBox(height: 23),
                _sectionHeading(
                  'Event Information',
                  'விழா விவரங்கள்',
                  Icons.celebration_rounded,
                ),
                const SizedBox(height: 13),
                _buildInfoCard([
                  _DetailRowData(
                    icon: Icons.event_rounded,
                    label: 'Event Type',
                    value: _display(booking.eventType),
                  ),
                  _DetailRowData(
                    icon: Icons.calendar_month_rounded,
                    label: 'Event Date',
                    value: _formatDate(booking.eventDate),
                  ),
                  _DetailRowData(
                    icon: Icons.access_time_rounded,
                    label: 'Event Time',
                    value: _display(booking.eventTime),
                  ),
                  _DetailRowData(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value: _display(booking.location),
                  ),
                  _DetailRowData(
                    icon: Icons.groups_rounded,
                    label: 'Number of Persons',
                    value: booking.numberOfPersons > 0
                        ? '${booking.numberOfPersons} persons'
                        : 'Not provided',
                  ),
                  if (booking.createdAt != null)
                    _DetailRowData(
                      icon: Icons.history_rounded,
                      label: 'Booking Created',
                      value: _formatDate(booking.createdAt),
                    ),
                ]),
                const SizedBox(height: 23),
                _sectionHeading(
                  'Catering Preferences',
                  'உணவு மற்றும் கேட்டரிங்',
                  Icons.restaurant_menu_rounded,
                ),
                const SizedBox(height: 13),
                _buildInfoCard([
                  _DetailRowData(
                    icon: Icons.room_service_rounded,
                    label: 'Catering Service',
                    value: _display(booking.cateringType),
                  ),
                  _DetailRowData(
                    icon: Icons.dinner_dining_rounded,
                    label: 'Meal Session',
                    value: _display(booking.mealType),
                  ),
                  _DetailRowData(
                    icon: Icons.restaurant_rounded,
                    label: 'Food Preference',
                    value: _display(booking.foodType),
                  ),
                  _DetailRowData(
                    icon: Icons.people_outline_rounded,
                    label: 'Catering Services',
                    value: booking.cateringServices.isEmpty
                        ? 'Not provided'
                        : booking.cateringServices.join(', '),
                  ),
                ]),
                if (booking.selectedFoods.isNotEmpty) ...[
                  const SizedBox(height: 23),
                  _sectionHeading(
                    'Selected Food Items',
                    'தேர்வு செய்த உணவுகள்',
                    Icons.restaurant_menu_rounded,
                  ),
                  const SizedBox(height: 13),
                  _buildSelectedFoods(),
                ],
                const SizedBox(height: 23),
                _sectionHeading(
                  'Payment Summary',
                  'கட்டண விவரங்கள்',
                  Icons.account_balance_wallet_rounded,
                ),
                const SizedBox(height: 13),
                _buildPaymentCard(booking),
                if (notes != 'Not provided') ...[
                  const SizedBox(height: 23),
                  _sectionHeading(
                    'Additional Requirements',
                    'கூடுதல் தேவைகள்',
                    Icons.notes_rounded,
                  ),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFECE3D5),
                      ),
                    ),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        color: _brown,
                        fontSize: 13,
                        height: 1.7,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 23),
                _buildStatusMessage(booking.status),
                const SizedBox(height: 22),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text(
                      'Back to My Bookings',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _brown,
                      side: const BorderSide(color: _gold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    String bookingId,
    String status,
    Color statusColor,
    String rawStatus,
  ) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF765039),
            _brown,
            _darkBrown,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _brown.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: _gold,
                  size: 29,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(rawStatus),
                        color: statusColor == Colors.blueGrey
                            ? Colors.white70
                            : statusColor,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          status,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusColor == Colors.blueGrey
                                ? Colors.white
                                : statusColor,
                            fontSize: 11,
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
          const SizedBox(height: 23),
          Text(
            'BOOKING REFERENCE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            bookingId.trim().isEmpty ? 'Not available' : bookingId,
            style: const TextStyle(
              color: Color(0xFFFFE6A2),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep this reference ID for future enquiries.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: _gold.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: _brown,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _brown,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF987022),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<_DetailRowData> details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
      ),
      child: Column(
        children: [
          for (int index = 0; index < details.length; index++) ...[
            _detailRow(details[index]),
            if (index < details.length - 1)
              const Divider(
                height: 25,
                color: Color(0xFFF0E8DC),
              ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(_DetailRowData detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          detail.icon,
          color: _gold,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                detail.value,
                style: const TextStyle(
                  color: _brown,
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

  Widget _buildSelectedFoods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
      ),
      child: Column(
        children: [
          for (int index = 0;
              index < widget.booking.selectedFoods.length;
              index++) ...[
            _foodRow(widget.booking.selectedFoods[index]),
            if (index < widget.booking.selectedFoods.length - 1)
              const Divider(
                height: 22,
                color: Color(0xFFF0E8DC),
              ),
          ],
        ],
      ),
    );
  }

  Widget _foodRow(Map<String, dynamic> food) {
    final name = (food['name'] ??
            food['foodName'] ??
            food['title'] ??
            'Food item')
        .toString();

    final quantity = food['quantity'] ?? food['count'];
    final subtitle = quantity == null ? '' : 'Quantity: $quantity';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.restaurant_rounded,
          color: _gold,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: _brown,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(BookingModel booking) {
    final total = booking.totalAmount;
    final advance = booking.advanceAmount;
    final balance = (total - advance).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
      ),
      child: Column(
        children: [
          _paymentRow('Estimated Total', _formatMoney(total)),
          const SizedBox(height: 13),
          _paymentRow('Advance Amount', _formatMoney(advance)),
          const Divider(
            height: 25,
            color: Color(0xFFF0E8DC),
          ),
          _paymentRow(
            'Balance Amount',
            _formatMoney(balance),
            emphasize: true,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _lightGold.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Text(
              'Final pricing and payment terms should be confirmed with the catering team.',
              style: TextStyle(
                color: Color(0xFF75561C),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow(
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasize ? _brown : _muted,
              fontSize: emphasize ? 13 : 12,
              fontWeight:
                  emphasize ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize
                ? const Color(0xFF21865B)
                : _brown,
            fontSize: emphasize ? 17 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(String? status) {
    final normalized = _normalizedStatus(status);

    final String title;
    final String message;
    final Color color;
    final IconData icon;

    if (normalized == 'confirmed') {
      title = 'Booking Confirmed';
      message =
          'Your catering booking has been confirmed. Contact the team if you need changes.';
      color = const Color(0xFF21865B);
      icon = Icons.verified_rounded;
    } else if (normalized == 'completed') {
      title = 'Event Completed';
      message =
          'This booking is marked as completed. Thank you for choosing Nivetha Catering Service.';
      color = const Color(0xFF326BC1);
      icon = Icons.task_alt_rounded;
    } else if (normalized == 'cancelled' ||
        normalized == 'rejected') {
      title = 'Booking Not Active';
      message =
          'This booking is cancelled or rejected. Contact the catering team if you need assistance.';
      color = const Color(0xFFC54646);
      icon = Icons.info_outline_rounded;
    } else {
      title = 'Awaiting Confirmation';
      message =
          'Your request is awaiting confirmation from the catering team. The booking is not finalized yet.';
      color = const Color(0xFFB27A17);
      icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message,
                  style: const TextStyle(
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

class _DetailRowData {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}
