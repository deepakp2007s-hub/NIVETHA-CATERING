
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../booking/booking_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../food/food_menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => screen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: _buildTopBar(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildWelcome(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                child: _buildHero(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
                child: _sectionHeading(
                  title: 'Our Services',
                  subtitle: 'Everything for your special day',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildListDelegate([
                  _serviceCard(
                    context,
                    icon: Icons.restaurant_menu_rounded,
                    title: 'Food Menu',
                    subtitle: 'Explore our menu',
                    color: AppColors.primary,
                    onTap: () => _openScreen(
                      context,
                      const FoodMenuScreen(),
                    ),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.event_available_rounded,
                    title: 'Book Catering',
                    subtitle: 'Plan your event',
                    color: AppColors.goldDark,
                    onTap: () => _openScreen(
                      context,
                      const BookingScreen(),
                    ),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.event_note_rounded,
                    title: 'My Bookings',
                    subtitle: 'View your events',
                    color: AppColors.primary,
                    onTap: () => _openScreen(
                      context,
                      const MyBookingsScreen(),
                    ),
                  ),
                  _serviceCard(
                    context,
                    icon: Icons.support_agent_rounded,
                    title: 'Contact Us',
                    subtitle: 'Get assistance',
                    color: AppColors.goldDark,
                    onTap: () => _showContactDialog(context),
                  ),
                ]),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 13,
                  mainAxisSpacing: 13,
                  childAspectRatio: 1.13,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: _sectionHeading(
                  title: 'Why Choose Us?',
                  subtitle: 'Making every occasion memorable',
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildBenefits(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: _buildFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: AppColors.goldAccent,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIVETHA',
                style: TextStyle(
                  color: AppColors.primaryGreenDark,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              Text(
                'CATERING SERVICE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: IconButton(
            tooltip: 'My Bookings',
            onPressed: () => _openScreen(
              context,
              const MyBookingsScreen(),
            ),
            icon: const Icon(
              Icons.event_note_rounded,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcome() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          'Vanakkam! 👋',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Make Your Celebrations Special',
          style: TextStyle(
            color: AppColors.primaryGreenDark,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
        ),
        SizedBox(height: 7),
        Text(
          'உங்கள் மகிழ்ச்சியான நிகழ்ச்சிகளுக்கு சுவையான விருந்து.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreenDark,
            AppColors.primary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -10,
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'YOUR SPECIAL DAY',
                  style: TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Great Food.\nBeautiful Memories.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Wedding, birthday, family functions and more.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () => _openScreen(
                    context,
                    const BookingScreen(),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Book Your Event',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                    foregroundColor: AppColors.primaryGreenDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.primaryGreenDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _serviceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 25,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primaryGreenDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Column(
        children: [
          _BenefitRow(
            icon: Icons.restaurant_rounded,
            title: 'Delicious Food',
            subtitle: 'Menu options for your special occasions',
          ),
          SizedBox(height: 18),
          _BenefitRow(
            icon: Icons.groups_rounded,
            title: 'Events of All Sizes',
            subtitle: 'Plan meals for your guests and functions',
          ),
          SizedBox(height: 18),
          _BenefitRow(
            icon: Icons.support_agent_rounded,
            title: 'Personal Assistance',
            subtitle: 'Discuss your catering requirements with us',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.55),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: AppColors.goldDark,
            size: 26,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Thank you for choosing Nivetha Catering Service!',
              style: TextStyle(
                color: AppColors.primaryGreenDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Contact Nivetha Catering'),
          content: const Text(
            'Please contact the catering team for event enquiries. '
            'The official phone number and contact link can be '
            'configured here once confirmed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.primaryGreenLight,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.primaryGreenDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
