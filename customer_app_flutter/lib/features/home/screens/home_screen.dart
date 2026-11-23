import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/food_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/food_service.dart';

/// Premium royal dashboard screen for Nivetha Catering customers.
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundSandal,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryCrimson,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryDeepWine,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.royalGold, width: 1.4),
                boxShadow: AppTheme.goldGlowShadow,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppTheme.royalGold,
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
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    _customer != null
                        ? 'Vanakkam, ${_customer!.name.split(' ').first} 🙏'
                        : 'Authentic Grand Feasts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.softChampagne,
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
              color: AppTheme.royalGold,
            ),
            onPressed: () => Navigator.pushNamed(context, '/menu'),
          ),
          IconButton(
            tooltip: 'My Bookings',
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: AppTheme.royalGold,
            ),
            onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryCrimson,
        backgroundColor: AppTheme.surfaceWhite,
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
              // Royal Hero Event Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: AppTheme.royalHeaderGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.royalGold.withValues(alpha: 0.65),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCrimson.withValues(alpha: 0.32),
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
                        color: AppTheme.primaryDeepWine.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.royalGold.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: AppTheme.royalGold,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'ROYAL SOUTH INDIAN FEASTS',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.softChampagne,
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
                      'Traditional Grand Feasts\nFor Every Celebration',
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
                        color: AppTheme.softChampagne,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldAccentGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.goldGlowShadow,
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppTheme.primaryDeepWine,
                          shadowColor: Colors.transparent,
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
                      subtitle: 'Browse signature dishes',
                      accentColor: AppTheme.bananaLeafGreen,
                      onTap: () => Navigator.pushNamed(context, '/menu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickActionCard(
                      icon: Icons.assignment_turned_in_rounded,
                      title: 'My Bookings',
                      subtitle: 'Track event status',
                      accentColor: AppTheme.primaryCrimson,
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
                      accentColor: AppTheme.primaryCrimson,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.celebration_rounded,
                      title: 'Engagements',
                      guestRange: '100 - 800 Guests',
                      accentColor: AppTheme.warmSaffron,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.cake_rounded,
                      title: 'Birthdays',
                      guestRange: '50 - 300 Guests',
                      accentColor: AppTheme.marigoldAmber,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.home_rounded,
                      title: 'Housewarming',
                      guestRange: '50 - 400 Guests',
                      accentColor: AppTheme.bananaLeafGreen,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                    _buildEventChip(
                      icon: Icons.business_center_rounded,
                      title: 'Corporate',
                      guestRange: '100 - 1500 Guests',
                      accentColor: AppTheme.royalTeal,
                      onTap: () =>
                          Navigator.pushNamed(context, '/create-booking'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Featured Delicacies Section (Photo-rich, Zero Price Display)
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
                          color: AppTheme.primaryCrimson,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppTheme.spiceRed.withValues(alpha: 0.3),
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
                              color: AppTheme.textMuted,
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
                        color: AppTheme.surfaceWhite,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.borderChampagne),
                      ),
                      child: const Center(
                        child: Text(
                          'No signature dishes available right now.',
                          style: TextStyle(color: AppTheme.textMuted),
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

              // Why Choose Nivetha Catering Luxury Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppTheme.royalGold.withValues(alpha: 0.55),
                    width: 1.2,
                  ),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            gradient: AppTheme.royalHeaderGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: AppTheme.royalGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'The Nivetha Royal Promise',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textEspresso,
                                ),
                              ),
                              Text(
                                'Excellence in every leaf & platter',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(height: 1),
                    ),
                    _buildPromiseRow(
                      Icons.eco_rounded,
                      AppTheme.bananaLeafGreen,
                      'Farm-Fresh & Pure Ingredients',
                      'Handpicked vegetables, aromatic spices & pure cow ghee.',
                    ),
                    const SizedBox(height: 14),
                    _buildPromiseRow(
                      Icons.groups_rounded,
                      AppTheme.primaryCrimson,
                      'Dedicated Hospitality Crew',
                      'Courteous serving staff, buffet supervisors & master chefs.',
                    ),
                    const SizedBox(height: 14),
                    _buildPromiseRow(
                      Icons.alarm_on_rounded,
                      AppTheme.warmSaffron,
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
            color: AppTheme.royalGold,
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
              color: AppTheme.textEspresso,
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
                  color: AppTheme.primaryCrimson,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppTheme.primaryCrimson,
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
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderChampagne, width: 1.2),
          boxShadow: AppTheme.cardShadow,
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
                      color: AppTheme.textEspresso,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
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
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderChampagne, width: 1.1),
          boxShadow: AppTheme.cardShadow,
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
                color: AppTheme.textEspresso,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              guestRange,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textMuted,
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
        food.isVegetarian ? AppTheme.bananaLeafGreen : AppTheme.spiceRed;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/menu'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 192,
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderChampagne, width: 1.1),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HD Food Photo Header (No Price Tag)
            Stack(
              children: [
                Container(
                  height: 122,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceTint,
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
                                color: AppTheme.primaryCrimson
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            size: 38,
                            color:
                                AppTheme.primaryCrimson.withValues(alpha: 0.35),
                          ),
                        ),
                ),
                // Subtle bottom vignette for visual depth
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(19),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.28),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Authentic Indian Veg / Non-Veg Square Badge
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
                // Royal Category Pill
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryDeepWine.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.royalGold.withValues(alpha: 0.6),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      food.formattedCategory,
                      style: const TextStyle(
                        color: AppTheme.softChampagne,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Dish Title & Description
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
                        color: AppTheme.textEspresso,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        food.description.isNotEmpty
                            ? food.description
                            : 'Prepared fresh for grand celebrations.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
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
                  color: AppTheme.textEspresso,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
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