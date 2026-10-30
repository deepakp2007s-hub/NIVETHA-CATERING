import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anna Owner'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              auth.ownerEmail ?? 'Owner',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 25),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: const [
                _DashboardCard(
                  title: 'Today Functions',
                  icon: Icons.event_available,
                ),
                _DashboardCard(
                  title: 'New Bookings',
                  icon: Icons.calendar_month,
                ),
                _DashboardCard(
                  title: 'Pending Bookings',
                  icon: Icons.pending_actions,
                ),
                _DashboardCard(
                  title: 'Upcoming Events',
                  icon: Icons.upcoming,
                ),
                _DashboardCard(
                  title: 'Reports',
                  icon: Icons.bar_chart,
                ),
                _DashboardCard(
                  title: 'Notifications',
                  icon: Icons.notifications_active_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: AppTheme.gold,
              size: 30,
            ),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}