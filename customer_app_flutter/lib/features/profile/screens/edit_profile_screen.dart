import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthProvider>().customer;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer?.name ?? '', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              customer?.phone ?? '',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile editing will use the live customer profile API in a later phase. Name and phone are the only fields the backend currently accepts.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
