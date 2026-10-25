
import 'package:flutter/material.dart';

import '../../../data/models/food_model.dart';

class FoodDetailsScreen extends StatefulWidget {
  final FoodModel food;

  const FoodDetailsScreen({
    super.key,
    required this.food,
  });

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen>
    with SingleTickerProviderStateMixin {
  static const Color brown = Color(0xFF45250E);
  static const Color darkBrown = Color(0xFF2E1B12);
  static const Color gold = Color(0xFFD5A64A);
  static const Color cream = Color(0xFFFFF8ED);
  static const Color muted = Color(0xFF806D59);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;

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
                SliverToBoxAdapter(
                  child: _buildImageHeader(food),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCategory(food.category),
                      const SizedBox(height: 15),
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 29,
                          height: 1.2,
                          color: darkBrown,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (food.tamilName.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          food.tamilName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color(0xFF9B762D),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 26),
                      _sectionTitle(
                        'About this dish',
                        'இந்த உணவைப் பற்றி',
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFECE3D5),
                          ),
                        ),
                        child: Text(
                          food.description.trim().isEmpty
                              ? 'Discover this delicious selection from Nivetha Catering Service.'
                              : food.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.8,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildInformationCard(food),
                      const SizedBox(height: 25),
                      _buildBookingButton(food),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'Nivetha Catering Service',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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

  Widget _buildImageHeader(FoodModel food) {
    return SizedBox(
      height: 310,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFFF0E5D2),
            child: _foodImage(food.image),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 18,
            child: _headerButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            top: 16,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.restaurant_rounded,
                    size: 16,
                    color: brown,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'NIVETHA',
                    style: TextStyle(
                      color: brown,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: brown.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'OUR FOOD COLLECTION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          if (!food.available)
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'UNAVAILABLE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _foodImage(String image) {
    if (image.trim().isEmpty) {
      return _imagePlaceholder();
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: CircularProgressIndicator(
            color: gold,
          ),
        );
      },
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.restaurant_rounded,
        color: Color(0xFFB7A17B),
        size: 100,
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: brown,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String category) {
    final text = category.trim().isEmpty ? 'Food' : category.trim();

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: gold.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: gold.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF89621D),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF987022),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(FoodModel food) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFECE3D5),
        ),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.restaurant_menu_rounded,
            'Category',
            food.category.trim().isEmpty ? 'Food' : food.category,
          ),
          const Divider(height: 25),
          _infoRow(
            food.available
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            'Availability',
            food.available ? 'Available' : 'Currently unavailable',
            valueColor: food.available
                ? const Color(0xFF247547)
                : Colors.red.shade700,
          ),
          const Divider(height: 25),
          _infoRow(
            Icons.event_note_rounded,
            'Catering',
            'Contact us for event packages',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: brown,
            size: 21,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? darkBrown,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingButton(FoodModel food) {
    final isAvailable = food.available;

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isAvailable
            ? () {
                Navigator.of(context).pushNamed('/booking');
              }
            : null,
        icon: Icon(
          isAvailable
              ? Icons.calendar_month_rounded
              : Icons.block_rounded,
        ),
        label: Text(
          isAvailable ? 'Book Catering Service' : 'Currently Unavailable',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: brown,
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 4,
          shadowColor: brown.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
