import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/empty_state.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(
                'My bookings',
                style: TextStyle(
                  fontFamily: 'BodoniModa',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Function catering requests appear here after they are submitted.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Expanded(
              child: Center(
                child: EmptyState(
                  title: 'No bookings yet',
                  message:
                      'When you submit a function catering request, its status will be shown here.',
                  icon: Icons.event_note_outlined,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.eventType);
                },
                child: const Text('Start booking request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
