
import 'package:flutter/material.dart';

import 'bookings/my_bookings_screen.dart';
import 'food/food_menu_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen>
    with SingleTickerProviderStateMixin {
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  int _selectedIndex = 0;

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    FoodMenuScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  final List<_NavigationItem> _items = const [
    _NavigationItem(
      label: 'Home',
      tamilLabel: 'முகப்பு',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavigationItem(
      label: 'Menu',
      tamilLabel: 'உணவு',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu_rounded,
    ),
    _NavigationItem(
      label: 'Bookings',
      tamilLabel: 'முன்பதிவு',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
    ),
    _NavigationItem(
      label: 'Profile',
      tamilLabel: 'சுயவிவரம்',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          for (int index = 0; index < _screens.length; index++)
            FadeTransition(
              opacity: _selectedIndex == index
                  ? _fadeAnimation
                  : const AlwaysStoppedAnimation<double>(1),
              child: _screens[index],
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border.all(
          color: const Color(0xFFECE3D5),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Row(
            children: [
              for (int index = 0; index < _items.length; index++)
                Expanded(
                  child: _buildNavigationItem(
                    index,
                    _items[index],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    int index,
    _NavigationItem item,
  ) {
    final selected = _selectedIndex == index;

    return Semantics(
      button: true,
      selected: selected,
      label: '${item.label}, ${item.tamilLabel}',
      child: GestureDetector(
        onTap: () => _selectTab(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(
            horizontal: 3,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? gold.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? gold.withValues(alpha: 0.38)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: selected ? 43 : 38,
                height: selected ? 36 : 33,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFFE6A2),
                            gold,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.20),
                            blurRadius: 9,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  color: selected ? navy : Colors.blueGrey.shade400,
                  size: selected ? 23 : 22,
                ),
              ),
              const SizedBox(height: 5),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected ? navy : Colors.blueGrey.shade500,
                  fontSize: 10,
                  fontWeight:
                      selected ? FontWeight.w900 : FontWeight.w600,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.tamilLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF987022)
                      : Colors.blueGrey.shade400,
                  fontSize: 8,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 5 : 0,
                height: 5,
                decoration: const BoxDecoration(
                  color: gold,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  final String label;
  final String tamilLabel;
  final IconData icon;
  final IconData selectedIcon;

  const _NavigationItem({
    required this.label,
    required this.tamilLabel,
    required this.icon,
    required this.selectedIcon,
  });
}
