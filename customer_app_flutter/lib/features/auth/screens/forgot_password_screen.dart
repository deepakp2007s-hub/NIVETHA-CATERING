import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password help')),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password reset is not available in this app.',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'The NIVETHA backend does not provide a password-reset endpoint. Please contact NIVETHA support to recover access to your account.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.contact),
            child: const Text('Contact support'),
          ),
        ),
      ),
    );
  }
}
