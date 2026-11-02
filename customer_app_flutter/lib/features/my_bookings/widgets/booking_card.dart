import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.bookingId,
    required this.functionType,
    required this.eventDate,
    required this.guestCount,
    required this.status,
    this.onTap,
  });

  final String bookingId;
  final String functionType;
  final String eventDate;
  final int guestCount;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(functionType),
      subtitle: Text('$bookingId · $eventDate · $guestCount guests'),
      trailing: Text(
        status,
        style: const TextStyle(color: AppColors.gold),
      ),
    );
  }
}
