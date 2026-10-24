
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
  static const Color navy = Color(0xFF102541);
  static const Color gold = Color(0xFFD9A441);
  static const Color cream = Color(0xFFFFF8EC);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.09),
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
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCategory(food.category),
                      const SizedBox(height: 15),
                      Text(
                        food.name,
                        style: const TextStyle(
                          fontSize: 29,
                          height: 1.2,
                          color: navy,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
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
                      const SizedBox(height: 22),
                      _buildPriceCard(food.price),
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
                              ? 'Enjoy this delicious selection from Nivetha Catering Service.'
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
                      _buildBookingButton(),
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
                  Colors.black.withValues(alpha: 0.32),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.12),
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
                    color: navy,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'NIVETHA',
                    style: TextStyle(
                      color: navy,
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
                color: navy.withValues(alpha: 0.88),
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
        ],
      ),
    );
  }

  Widget _foodImage(String image) {
    if (image.trim().isEmpty) {
      return const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: Color(0xFFB7A17B),
          size: 100,
        ),
      );
    }

    return Image.network(
      image,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const Center(
          child: Icon(
            Icons.restaurant_rounded,
            color: Color(0xFFB7A17B),
            size: 100,
          ),
        );
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
            color: navy,
            size: 23,
          ),
        ),
      ),
    );
  }

  Widget _buildCategory(String category) {
    final text = category.trim().isEmpty ? 'Food' : category;

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
            color: gold.withValues(alpha: 0.35),
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

  Widget _buildPriceCard(double price) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF25496C),
            navy,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.currency_rupee_rounded,
              color: gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Menu Price',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  price > 0
                      ? '₹${price.toStringAsFixed(0)}'
                      : 'Price on request',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            color: gold,
            size: 25,
          ),
        ],
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
            color: navy,
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
            food.category.isEmpty ? 'Food' : food.category,
          ),
          const Divider(height: 25),
          _infoRow(
            Icons.check_circle_outline_rounded,
            'Availability',
            food.available ? 'Available' : 'Currently unavailable',
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
    String value,
  ) {
    return Row(
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
            color: navy,
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
                style: TextStyle(
                  color: Colors.blueGrey.shade500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: navy,
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

  Widget _buildBookingButton() {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).pushNamed('/booking');
        },
        icon: const Icon(Icons.calendar_month_rounded),
        label: const Text(
          'Book Catering Service',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: navy.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
