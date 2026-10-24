
import 'package:flutter/material.dart';

import '../booking/booking_screen.dart';
import '../bookings/my_bookings_screen.dart';
import '../food/food_menu_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openPage(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(),
                      const SizedBox(height: 25),
                      _buildHeroBanner(),
                      const SizedBox(height: 30),
                      _buildSectionTitle(
                        'Our Services',
                        'உங்கள் விழாவிற்கு சிறந்த சேவை',
                      ),
                      const SizedBox(height: 17),
                      _buildServiceGrid(),
                      const SizedBox(height: 30),
                      _buildSectionTitle(
                        'Why Choose Us?',
                        'உங்கள் மகிழ்ச்சியே எங்கள் நோக்கம்',
                      ),
                      const SizedBox(height: 17),
                      _buildBenefits(),
                      const SizedBox(height: 28),
                      _buildContactCard(),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          'Nivetha Catering Service • Made with care',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blueGrey.shade500,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFE6A2),
                gold,
                Color(0xFFB77B25),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.restaurant_menu_rounded,
            color: navy,
            size: 30,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NIVETHA',
                style: TextStyle(
                  color: navy,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Catering Service',
                style: TextStyle(
                  color: Color(0xFF9B762D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _roundIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: () => _openPage(const NotificationsScreen()),
        ),
        const SizedBox(width: 9),
        _roundIconButton(
          icon: Icons.person_outline_rounded,
          onTap: () => _openPage(const ProfileScreen()),
        ),
      ],
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFECE2D1),
            ),
          ),
          child: Icon(
            icon,
            color: navy,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF25496C),
            navy,
            Color(0xFF091629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -10,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 100,
              color: gold.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: gold.withValues(alpha: 0.45),
                  ),
                ),
                child: const Text(
                  '✨  MAKE YOUR EVENT SPECIAL',
                  style: TextStyle(
                    color: Color(0xFFFFE6A2),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Every Celebration\nDeserves Great Food!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                'சுவையான உணவு • சிறப்பான சேவை',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 23),
              SizedBox(
                height: 49,
                child: ElevatedButton.icon(
                  onPressed: () => _openPage(const BookingScreen()),
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                    size: 19,
                  ),
                  label: const Text(
                    'Book Your Event',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: navy,
                    backgroundColor: gold,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 19,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: navy,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.blueGrey.shade600,
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      _ServiceItem(
        title: 'Food Menu',
        subtitle: 'Explore our dishes',
        tamil: 'உணவு வகைகள்',
        icon: Icons.restaurant_rounded,
        color: const Color(0xFFDAA441),
        onTap: () => _openPage(const FoodMenuScreen()),
      ),
      _ServiceItem(
        title: 'Book Catering',
        subtitle: 'Plan your event',
        tamil: 'விழாவை பதிவு செய்க',
        icon: Icons.event_available_rounded,
        color: const Color(0xFF2C7894),
        onTap: () => _openPage(const BookingScreen()),
      ),
      _ServiceItem(
        title: 'My Bookings',
        subtitle: 'View your bookings',
        tamil: 'என் பதிவுகள்',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF6C65AD),
        onTap: () => _openPage(const MyBookingsScreen()),
      ),
      _ServiceItem(
        title: 'My Profile',
        subtitle: 'Your account details',
        tamil: 'என் விவரங்கள்',
        icon: Icons.account_circle_rounded,
        color: const Color(0xFF45866A),
        onTap: () => _openPage(const ProfileScreen()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13,
        mainAxisSpacing: 13,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        return _AnimatedServiceCard(item: services[index]);
      },
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      (
        Icons.restaurant_menu_rounded,
        'Delicious Food',
        'சுவையான உணவு வகைகள்',
      ),
      (
        Icons.groups_rounded,
        'Professional Service',
        'சிறந்த சேவை',
      ),
      (
        Icons.event_available_rounded,
        'Events Made Easy',
        'எளிய முன்பதிவு',
      ),
    ];

    return Column(
      children: benefits.map((benefit) {
        return Container(
          margin: const EdgeInsets.only(bottom: 11),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFEDE4D6),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  benefit.$1,
                  color: navy,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit.$2,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      benefit.$3,
                      style: TextStyle(
                        color: Colors.blueGrey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF42856A),
                size: 21,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBC0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: navy,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need Help?',
                  style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Contact us for your event needs.',
                  style: TextStyle(
                    color: Color(0xFF655431),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Contact details',
            onPressed: _showContactDialog,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          icon: const Icon(
            Icons.restaurant_menu_rounded,
            color: gold,
            size: 42,
          ),
          title: const Text(
            'Nivetha Catering Service',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: navy,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          content: const Text(
            'For booking assistance, please contact the catering service directly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.6,
              fontSize: 14,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceItem {
  final String title;
  final String subtitle;
  final String tamil;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.tamil,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _AnimatedServiceCard extends StatefulWidget {
  final _ServiceItem item;

  const _AnimatedServiceCard({
    required this.item,
  });

  @override
  State<_AnimatedServiceCard> createState() =>
      _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170),
      lowerBound: 0,
      upperBound: 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;

    setState(() => _pressed = value);

    if (value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: item.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1 - (_controller.value * 0.035);
          final tilt = _controller.value * 0.025;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(tilt)
              ..scaleByDouble(scale, scale, 1, 1),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 16, 13, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFECE3D5),
            ),
            boxShadow: [
              BoxShadow(
                color: item.color.withValues(alpha: 0.11),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item.color.withValues(alpha: 0.18),
                      item.color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item.icon,
                  color: item.color,
                  size: 27,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF102541),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.blueGrey.shade600,
                  fontSize: 10.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.tamil,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9B762D),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      color: Color(0xFF102541),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: item.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
