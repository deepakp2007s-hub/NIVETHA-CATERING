import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/food_service.dart';

/// Fresh emerald & champagne gold dashboard screen for Nivetha Catering customers.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _featuredLimit = 10;

  // Fresh Emerald & Warm Champagne Gold Palette
  static const Color _forestEmerald = Color(0xFF144536);
  static const Color _deepForest = Color(0xFF0C2E24);
  static const Color _champagneGold = Color(0xFFD9A441);
  static const Color _softIvory = Color(0xFFFBF9F5);
  static const Color _warmSandBorder = Color(0xFFE5DEC9);
  static const Color _inkDark = Color(0xFF1A2421);
  static const Color _inkMuted = Color(0xFF5A6863);

  final FoodService _foodService = FoodService();
  final AuthService _authService = AuthService();

  CustomerModel? _customer;
  late Future<List<FoodModel>> _foodsFuture;

  @override
  void initState() {
    super.initState();
    _loadCustomerInfo();
    _foodsFuture = _fetchFoods();
  }

  Future<void> _loadCustomerInfo() async {
    final customer = await _authService.getCurrentCustomer();

    if (!mounted) return;

    if (customer != null) {
      setState(() => _customer = customer);
      return;
    }

    // getCurrentCustomer() clears the session on a 401 (expired token).
    // If no session is left, send the user back to login.
    final stillLoggedIn = await _authService.isLoggedIn();
    if (!mounted) return;

    if (!stillLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<List<FoodModel>> _fetchFoods() async {
    final foods = await _foodService.getFoods(availableOnly: true);
    return foods.take(_featuredLimit).toList();
  }

  void _reloadFoods() {
    setState(() {
      _foodsFuture = _fetchFoods();
    });
  }

  String _cleanError(Object? error) {
    return (error?.toString() ?? 'Something went wrong')
        .replaceAll('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softIvory,
      appBar: AppBar(
        backgroundColor: _forestEmerald,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _deepForest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _champagneGold, width: 1.4),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: _champagneGold,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'NIVETHA CATERING',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _customer != null
                        ? 'Vanakkam, ${_customer!.name.split(' ').first}'
                        : 'Bespoke Event Catering',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFF6E7C1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'View Food Menu',
            icon: const Icon(
              Icons.restaurant_menu_rounded,
              color: _champagneGold,
            ),
            onPressed: () => Navigator.pushNamed(context, '/menu'),
          ),
          IconButton(
            tooltip: 'My Bookings',
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: _champagneGold,
            ),
            onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        color: _forestEmerald,
        backgroundColor: Colors.white,
        onRefresh: () async {
          _loadCustomerInfo();
          _reloadFoods();
          try {
            await _foodsFuture;
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emerald & Gold Invitation Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_forestEmerald, Color(0xFF1E634D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _champagneGold.withValues(alpha: 0.75),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _deepForest.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _deepForest.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _champagneGold.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: _champagneGold,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'BANANA LEAF HOSPITALITY',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFF6E7C1),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Warm Feasts Crafted\nFor Your Special Day',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Weddings, Engagements, Housewarmings, Corporate Banquets & Family Functions.',
                      style: TextStyle(
                        color: Color(0xFFE6F0EC),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _champagneGold,
                        foregroundColor: _deepForest,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                      icon: const Icon(Icons.calendar_month_rounded, size: 20),
                      label: const Text(
                        'Book Catering Event',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Feature Actions
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Explore Menu',
                      subtitle: 'Browse dishes',
                      accentColor: _forestEmerald,
                      onTap: () => Navigator.pushNamed(context, '/menu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'My Bookings',
                      subtitle: 'Track event status',
                      accentColor: const Color(0xFFB46916),
                      onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Catering Occasions Section
              _buildSectionHeader(
                title: 'Occasions We Cater',
                actionLabel: 'Book Event',
                onAction: () => Navigator.pushNamed(context, '/create-booking'),
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                child: Row(
                  children: [
                    _buildEventChip(
                      icon: Icons.favorite_rounded,
                      title: 'Weddings',
                      guestRange: '300 - 5000+ Guests',
                      accentColor: _forestEmerald,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.celebration_rounded,
                      title: 'Engagements',
                      guestRange: '100 - 800 Guests',
                      accentColor: const Color(0xFFB46916),
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.cake_rounded,
                      title: 'Birthdays',
                      guestRange: '50 - 300 Guests',
                      accentColor: const Color(0xFF9C4221),
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.home_rounded,
                      title: 'Housewarming',
                      guestRange: '50 - 400 Guests',
                      accentColor: const Color(0xFF1E634D),
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.business_center_rounded,
                      title: 'Corporate',
                      guestRange: '100 - 1500 Guests',
                      accentColor: const Color(0xFF1D4E56),
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Featured Delicacies Section (Live Owner Items Only, Zero Price Display)
              _buildSectionHeader(
                title: 'Signature Delicacies',
                actionLabel: 'Full Menu',
                onAction: () => Navigator.pushNamed(context, '/menu'),
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<FoodModel>>(
                future: _foodsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 210,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _forestEmerald,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.spiceRed.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: AppTheme.spiceRed,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cleanError(snapshot.error),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _inkMuted,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _reloadFoods,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final foods = snapshot.data ?? [];
                  if (foods.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _warmSandBorder),
                      ),
                      child: const Center(
                        child: Text(
                          'No dishes added yet. Items added by Nivetha Catering will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: _inkMuted),
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: foods.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        return _buildFeaturedFoodCard(context, foods[index]);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Why Choose Nivetha Catering Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _champagneGold.withValues(alpha: 0.65),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _deepForest.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: _forestEmerald,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: _champagneGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Nivetha Promise',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: _inkDark,
                                ),
                              ),
                              Text(
                                'Warmth & care in every serving',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: _inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1, color: _warmSandBorder),
                    ),
                    _buildPromiseRow(
                      Icons.eco_rounded,
                      _forestEmerald,
                      'Farm-Fresh & Pure Ingredients',
                      'Handpicked vegetables, aromatic spices & pure cow ghee.',
                    ),
                    const SizedBox(height: 14),
                    _buildPromiseRow(
                      Icons.groups_rounded,
                      const Color(0xFFB46916),
                      'Dedicated Hospitality Crew',
                      'Courteous serving staff, buffet supervisors & master chefs.',
                    ),
                    const SizedBox(height: 14),
                    _buildPromiseRow(
                      Icons.alarm_on_rounded,
                      const Color(0xFF1D4E56),
                      'Punctual & Hygienic Setup',
                      'On-time venue setup, sanitized live counters & spotless cutlery.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _champagneGold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: _inkDark,
              letterSpacing: -0.2,
            ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  color: _forestEmerald,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: _forestEmerald,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _warmSandBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: _deepForest.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: _inkDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventChip({
    required IconData icon,
    required String title,
    required String guestRange,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _warmSandBorder, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: _deepForest.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: _inkDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              guestRange,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: _inkMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedFoodCard(BuildContext context, FoodModel food) {
    final dietaryColor =
        food.isVegetarian ? const Color(0xFF1E7E48) : const Color(0xFFC62828);

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/menu'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 192,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _warmSandBorder, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: _deepForest.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Photo Header (No Price Tag)
            Stack(
              children: [
                Container(
                  height: 122,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: _softIvory,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                  ),
                  child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(19),
                          ),
                          child: Image.network(
                            food.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 38,
                                color: _forestEmerald.withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 38,
                            color: _forestEmerald.withValues(alpha: 0.35),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: dietaryColor, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dietaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _deepForest.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _champagneGold.withValues(alpha: 0.65),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      food.formattedCategory,
                      style: const TextStyle(
                        color: Color(0xFFF6E7C1),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: _inkDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        food.description.isNotEmpty
                            ? food.description
                            : 'Event Special • Prepared fresh for celebrations.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _inkMuted,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseRow(
    IconData icon,
    Color iconColor,
    String title,
    String desc,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: _inkDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: _inkMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}