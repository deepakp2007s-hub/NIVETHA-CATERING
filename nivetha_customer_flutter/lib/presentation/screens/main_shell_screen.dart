
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import 'home/home_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    if (index < 0 || index > 3) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final screens = <Widget>[
      HomeScreen(
        onNavigateToMenu: () => _switchTab(1),
        onNavigateToBooking: () => _switchTab(2),
      ),
      _buildPlaceholderTab(
        title: loc.translate('menu'),
        icon: Icons.restaurant_menu_rounded,
        subtitle: 'Explore vegetarian and non-vegetarian catering menus.',
        features: const [
          'Breakfast, lunch and dinner',
          'Vegetarian and non-vegetarian options',
          'Custom menu requests',
        ],
        actionLabel: 'Back to Home',
      ),
      _buildPlaceholderTab(
        title: loc.translate('bookings'),
        icon: Icons.event_note_rounded,
        subtitle: 'Plan your event and manage your catering bookings.',
        features: const [
          'Choose your event type',
          'Add event date and location',
          'Track booking status',
        ],
        actionLabel: 'Back to Home',
      ),
      _buildPlaceholderTab(
        title: loc.translate('profile'),
        icon: Icons.person_rounded,
        subtitle: 'Your personal details and booking information.',
        features: const [
          'Customer details',
          'Booking history',
          'Account settings',
        ],
        actionLabel: 'Back to Home',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border(
            top: BorderSide(
              color: AppColors.goldAccent.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreenDark.withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          backgroundColor: AppColors.surfaceWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          selectedIndex: _currentIndex,
          onDestinationSelected: _switchTab,
          indicatorColor: AppColors.surfaceGreen,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 350),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: loc.translate('home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.restaurant_menu_outlined),
              selectedIcon: const Icon(Icons.restaurant_menu_rounded),
              label: loc.translate('menu'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_note_outlined),
              selectedIcon: const Icon(Icons.event_note_rounded),
              label: loc.translate('bookings'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline_rounded),
              selectedIcon: const Icon(Icons.person_rounded),
              label: loc.translate('profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab({
    required String title,
    required IconData icon,
    required String subtitle,
    required List<String> features,
    required String actionLabel,
  }) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreenDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.goldAccent.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: AppColors.goldAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primaryGreenDark,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.goldAccent,
                            size: 16,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'NIVETHA CATERING',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'What you can explore',
                style: TextStyle(
                  color: AppColors.primaryGreenDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              ...features.asMap().entries.map((entry) {
                final index = entry.key;
                final feature = entry.value;

                final icons = [
                  Icons.check_circle_rounded,
                  Icons.stars_rounded,
                  Icons.event_available_rounded,
                ];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        icons[index % icons.length],
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _switchTab(0),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(actionLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(
                      color: AppColors.primaryGreen,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
