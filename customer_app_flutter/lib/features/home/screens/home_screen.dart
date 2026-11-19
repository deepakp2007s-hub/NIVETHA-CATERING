import 'package:flutter/material.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/food_service.dart';

/// Premium home dashboard screen for Nivetha Catering customers.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _featuredLimit = 10;

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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Icon(Icons.restaurant_rounded, color: primaryColor, size: 22),
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
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    _customer != null
                        ? 'Vanakkam, ${_customer!.name.split(' ').first}'
                        : 'Authentic Grand Feasts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
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
            icon: const Icon(Icons.restaurant_menu_rounded),
            onPressed: () => Navigator.pushNamed(context, '/menu'),
          ),
          IconButton(
            tooltip: 'My Bookings',
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCustomerInfo();
          _reloadFoods();
          try {
            await _foodsFuture;
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Event Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFC85A17), // Deep warm terracotta
                      Color(0xFFE65100), // Vibrant amber
                      Color(0xFFF57C00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFC85A17).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: Colors.amberAccent,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'PREMIUM CATERING SERVICE',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Traditional Grand Feasts\nFor Your Special Occasion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Weddings, Engagements, Housewarmings, Corporate Banquets, and Family Celebrations.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFC85A17),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                      icon: const Icon(Icons.calendar_month_rounded, size: 20),
                      label: const Text(
                        'Book Catering Event',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                      title: 'Food Menu',
                      subtitle: 'Browse our dishes',
                      color: const Color(0xFF2E7D32),
                      onTap: () => Navigator.pushNamed(context, '/menu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'My Bookings',
                      subtitle: 'Track status live',
                      color: const Color(0xFF1565C0),
                      onTap: () => Navigator.pushNamed(context, '/my-bookings'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Catering Occasions Section
              _buildSectionHeader(
                title: 'Occasions We Cater',
                actionLabel: 'Book Now',
                onAction: () => Navigator.pushNamed(context, '/create-booking'),
                primaryColor: primaryColor,
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
                      color: Colors.pink.shade700,
                    ),
                    _buildEventChip(
                      icon: Icons.celebration_rounded,
                      title: 'Engagements',
                      guestRange: '100 - 800 Guests',
                      color: Colors.deepPurple.shade700,
                    ),
                    _buildEventChip(
                      icon: Icons.cake_rounded,
                      title: 'Birthdays',
                      guestRange: '50 - 300 Guests',
                      color: Colors.amber.shade800,
                    ),
                    _buildEventChip(
                      icon: Icons.home_rounded,
                      title: 'Housewarming',
                      guestRange: '50 - 400 Guests',
                      color: Colors.teal.shade700,
                    ),
                    _buildEventChip(
                      icon: Icons.business_center_rounded,
                      title: 'Corporate Galas',
                      guestRange: '100 - 1500 Guests',
                      color: Colors.blueGrey.shade800,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Featured Delicacies Section
              _buildSectionHeader(
                title: 'Specialty Dishes',
                actionLabel: 'View All',
                onAction: () => Navigator.pushNamed(context, '/menu'),
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 12),

              FutureBuilder<List<FoodModel>>(
                future: _foodsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.red,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _cleanError(snapshot.error),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: _reloadFoods,
                            child: const Text('Retry'),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('No specialty dishes found.'),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 220,
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

              const SizedBox(height: 32),

              // Why Choose Nivetha Catering Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
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
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'The Nivetha Catering Promise',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildPromiseRow(
                      Icons.eco_rounded,
                      'Fresh & Pure Ingredients',
                      'Farm-sourced vegetables and pure cow ghee for authentic flavors.',
                    ),
                    const SizedBox(height: 12),
                    _buildPromiseRow(
                      Icons.groups_rounded,
                      'Trained Hospitality Crew',
                      'Courteous serving staff, buffet supervisors, and master chefs.',
                    ),
                    const SizedBox(height: 12),
                    _buildPromiseRow(
                      Icons.alarm_on_rounded,
                      'Punctual & Hygienic Setup',
                      'Timely food delivery, sanitized live counters, and pristine cutlery.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
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
    required Color primaryColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFF1F2937),
                ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
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
    required Color color,
  }) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            guestRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedFoodCard(BuildContext context, FoodModel food) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/menu'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Header
            Stack(
              children: [
                Container(
                  height: 105,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: food.imageUrl != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            food.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.restaurant_rounded,
                                size: 36,
                                color: Colors.orange.shade300,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 36,
                            color: Colors.orange.shade300,
                          ),
                        ),
                ),
                // Dietary Indicator Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: food.isVegetarian
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFC62828),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                // Category Chip
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      food.formattedCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (food.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      food.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromiseRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFC85A17), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}