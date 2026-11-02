import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customer = auth.customer;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'BodoniModa',
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer?.name.isNotEmpty == true
                        ? customer!.name
                        : 'NIVETHA guest',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    customer?.email ?? '',
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  if (customer?.phone.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      customer!.phone,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ProfileTile(
              icon: Icons.edit_outlined,
              label: 'Edit profile',
              onTap: () => Navigator.pushNamed(context, AppRouter.editProfile),
            ),
            _ProfileTile(
              icon: Icons.event_available_outlined,
              label: 'My bookings',
              onTap: () => Navigator.pushNamed(context, AppRouter.myBookings),
            ),
            _ProfileTile(
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.notifications),
            ),
            _ProfileTile(
              icon: Icons.support_agent_outlined,
              label: 'Contact support',
              onTap: () => Navigator.pushNamed(context, AppRouter.contact),
            ),
            _ProfileTile(
              icon: Icons.feedback_outlined,
              label: 'Feedback',
              onTap: () => Navigator.pushNamed(context, AppRouter.feedback),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.login,
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.gold),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
