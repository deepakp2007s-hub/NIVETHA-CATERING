
import 'package:flutter/material.dart';

import 'booking/booking_screen.dart';
import 'bookings/my_bookings_screen.dart';
import 'food/food_menu_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen>
    with SingleTickerProviderStateMixin {
  static const Color _cream = Color(0xFFFFF8ED);
  static const Color _darkBrown = Color(0xFF402719);
  static const Color _brown = Color(0xFF765039);
  static const Color _gold = Color(0xFFD5A64A);
  static const Color _lightGold = Color(0xFFF5E5C2);

  late int _selectedIndex;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    FoodMenuScreen(),
    BookingScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  final List<_NavigationItem> _navigationItems = const [
    _NavigationItem(
      label: 'Home',
      tamilLabel: 'முகப்பு',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavigationItem(
      label: 'Food Menu',
      tamilLabel: 'உணவு',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu_rounded,
    ),
    _NavigationItem(
      label: 'Book',
      tamilLabel: 'முன்பதிவு',
      icon: Icons.event_available_outlined,
      selectedIcon: Icons.event_available_rounded,
    ),
    _NavigationItem(
      label: 'My Bookings',
      tamilLabel: 'என் முன்பதிவுகள்',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
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

    _selectedIndex = widget.initialIndex
        .clamp(0, _screens.length - 1)
        .toInt();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: 1,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index < 0 || index >= _screens.length) return;
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0 && mounted) {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        backgroundColor: _cream,
        body: IndexedStack(
          index: _selectedIndex,
          children: List<Widget>.generate(
            _screens.length,
            (index) {
              if (index == _selectedIndex) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: _screens[index],
                );
              }

              return _screens[index];
            },
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
        border: const Border(
          top: BorderSide(
            color: _lightGold,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: _darkBrown.withValues(alpha: 0.09),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 9, 5, 7),
          child: Row(
            children: List.generate(
              _navigationItems.length,
              (index) => Expanded(
                child: _buildNavigationItem(
                  item: _navigationItems[index],
                  index: index,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required _NavigationItem item,
    required int index,
  }) {
    final selected = _selectedIndex == index;

    return Semantics(
      button: true,
      selected: selected,
      label: '${item.label}, ${item.tamilLabel}',
      child: InkWell(
        onTap: () => _onItemTapped(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: selected
                ? _gold.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? _gold.withValues(alpha: 0.28)
                  : Colors.transparent,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 13 : 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFFFFE6A2),
                            _gold,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: _gold.withValues(alpha: 0.20),
                            blurRadius: 9,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : const [],
                ),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  size: selected ? 22 : 21,
                  color: selected
                      ? _darkBrown
                      : Colors.blueGrey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: selected
                      ? _darkBrown
                      : Colors.blueGrey.shade600,
                  fontSize: 9,
                  fontWeight: selected
                      ? FontWeight.w900
                      : FontWeight.w600,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.tamilLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? _brown
                      : Colors.blueGrey.shade400,
                  fontSize: 8,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: selected ? 5 : 0,
                height: 5,
                decoration: const BoxDecoration(
                  color: _gold,
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
  const _NavigationItem({
    required this.label,
    required this.tamilLabel,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String tamilLabel;
  final IconData icon;
  final IconData selectedIcon;
}
