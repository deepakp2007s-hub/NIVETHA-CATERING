import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customer = context.watch<AuthProvider>().customer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nivetha Catering'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vanakkam, ${customer?.name ?? 'Guest'}',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Your customer account is ready.',
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.celebration_outlined,
                            size: 38,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Browse our catering menu and plan food for your special event.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Home, menu, bookings, profile, notifications, and reviews will be connected in the next feature pass.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
