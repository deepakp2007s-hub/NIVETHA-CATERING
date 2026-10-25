import 'package:flutter/material.dart';

import '../booking/booking_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../food/food_menu_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const Color _cream = Color(0xFFFFF8ED);
  static const Color _darkBrown = Color(0xFF402719);
  static const Color _brown = Color(0xFF765039);
  static const Color _gold = Color(0xFFD5A64A);
  static const Color _lightGold = Color(0xFFF5E5C2);

  late final List<Widget> _screens = [
    _buildHomeContent(),
    const FoodMenuScreen(),
    const BookingScreen(),
    const MyBookingsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _screens[0] = _buildHomeContent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _darkBrown.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 'Home', 0),
                _navItem(Icons.restaurant_menu_rounded, 'Food Menu', 1),
                _navItem(Icons.event_available_rounded, 'Book', 2),
                _navItem(Icons.receipt_long_rounded, 'My Bookings', 3),
                _navItem(Icons.person_rounded, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final bool selected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _onItemTapped(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: selected ? _lightGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? _darkBrown : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w500,
                  color: selected ? _darkBrown : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildWelcomeBanner(),
          const SizedBox(height: 26),
          _buildSectionHeading(
            'What are you planning?',
            'Choose a service for your function',
          ),
          const SizedBox(height: 16),
          _buildServiceGrid(),
          const SizedBox(height: 28),
          _buildSectionHeading(
            'Popular Food Categories',
            'Delicious choices for every occasion',
          ),
          const SizedBox(height: 16),
          _buildFoodCategories(),
          const SizedBox(height: 28),
          _buildSpecialBanner(),
          const SizedBox(height: 28),
          _buildSectionHeading(
            'Why Choose Nivetha?',
            'We make your special day memorable',
          ),
          const SizedBox(height: 16),
          _buildBenefits(),
          const SizedBox(height: 24),
          _buildContactCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: _darkBrown,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: _gold, width: 1.5),
          ),
          child: const Icon(
            Icons.restaurant_rounded,
            color: _gold,
            size: 29,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NIVETHA',
                style: TextStyle(
                  color: _darkBrown,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'CATERING SERVICE',
                style: TextStyle(
                  color: _brown.withValues(alpha: 0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _onItemTapped(4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _lightGold),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: _darkBrown,
                size: 25,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF503322),
            Color(0xFF2E1B12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _gold.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -12,
            child: Icon(
              Icons.spa_rounded,
              size: 120,
              color: _gold.withValues(alpha: 0.09),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _gold.withValues(alpha: 0.6),
                  ),
                ),
                child: const Text(
                  '✦  MADE WITH LOVE',
                  style: TextStyle(
                    color: _gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Make Every\nCelebration Special',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Authentic taste. Beautiful memories.\nExceptional catering for your special day.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _onItemTapped(2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: _darkBrown,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 19,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Book Your Function',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _darkBrown,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: _brown.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      {
        'title': 'Wedding',
        'subtitle': 'Grand celebrations',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFF8E5D8),
      },
      {
        'title': 'Engagement',
        'subtitle': 'Beautiful beginnings',
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFFF3E9D0),
      },
      {
        'title': 'Birthday',
        'subtitle': 'Celebrate with joy',
        'icon': Icons.cake_rounded,
        'color': const Color(0xFFF7E2E5),
      },
      {
        'title': 'House Function',
        'subtitle': 'Family gatherings',
        'icon': Icons.home_rounded,
        'color': const Color(0xFFE7ECDD),
      },
      {
        'title': 'Corporate',
        'subtitle': 'Professional events',
        'icon': Icons.business_center_rounded,
        'color': const Color(0xFFE2EAF3),
      },
      {
        'title': 'Other Events',
        'subtitle': 'Your special occasion',
        'icon': Icons.celebration_rounded,
        'color': const Color(0xFFECE2F3),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.42,
      ),
      itemBuilder: (context, index) {
        final service = services[index];

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _onItemTapped(2),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _lightGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: service['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      service['icon'] as IconData,
                      color: _darkBrown,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service['title'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _darkBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service['subtitle'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodCategories() {
    final categories = [
      {
        'name': 'Breakfast',
        'emoji': '🥞',
        'description': 'Morning favourites',
      },
      {
        'name': 'Lunch',
        'emoji': '🍛',
        'description': 'Traditional meals',
      },
      {
        'name': 'Dinner',
        'emoji': '🍽️',
        'description': 'Delicious dinners',
      },
      {
        'name': 'Sweets',
        'emoji': '🍮',
        'description': 'Sweet memories',
      },
    ];

    return SizedBox(
      height: 125,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];

          return InkWell(
            onTap: () => _onItemTapped(1),
            borderRadius: BorderRadius.circular(17),
            child: Container(
              width: 142,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: _lightGold),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category['emoji']!,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Spacer(),
                  Text(
                    category['name']!,
                    style: const TextStyle(
                      color: _darkBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category['description']!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecialBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E6CA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _darkBrown,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: _gold,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Feast to Remember',
                  style: TextStyle(
                    color: _darkBrown,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Explore our menu and plan your perfect feast.',
                  style: TextStyle(
                    color: _brown,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _onItemTapped(1),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: _darkBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {
        'icon': Icons.restaurant_menu_rounded,
        'title': 'Authentic Taste',
        'description': 'Delicious food prepared with care.',
      },
      {
        'icon': Icons.groups_rounded,
        'title': 'Experienced Team',
        'description': 'Friendly cooking and serving staff.',
      },
      {
        'icon': Icons.event_available_rounded,
        'title': 'Easy Booking',
        'description': 'Plan your event in a few simple steps.',
      },
    ];

    return Column(
      children: benefits.map((benefit) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _lightGold),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lightGold.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  benefit['icon'] as IconData,
                  color: _darkBrown,
                  size: 23,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: const TextStyle(
                        color: _darkBrown,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit['description'] as String,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF65814D),
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkBrown,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent_rounded,
            color: _gold,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'Need Help Planning Your Event?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Choose your menu, share your requirements, and plan your special day.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _onItemTapped(2),
            style: OutlinedButton.styleFrom(
              foregroundColor: _gold,
              side: const BorderSide(color: _gold),
              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Plan My Function',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}