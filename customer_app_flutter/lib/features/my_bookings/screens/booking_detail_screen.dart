import 'package:flutter/material.dart';

import '../../../shared/widgets/empty_state.dart';

class BookingDetailScreen extends StatelessWidget {
  const BookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: const Center(
        child: EmptyState(
          title: 'Booking details',
          message:
              'Complete booking information will appear here after a request is loaded from the live booking API.',
        ),
      ),
    );
  }
}
