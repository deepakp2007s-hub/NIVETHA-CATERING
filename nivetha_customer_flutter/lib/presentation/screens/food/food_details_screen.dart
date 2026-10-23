
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/food_model.dart';
import '../booking/booking_screen.dart';

class FoodDetailsScreen extends StatelessWidget {
  final FoodModel food;

  const FoodDetailsScreen({
    super.key,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    final isTamil = food.tamilName.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Food Details'),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 1.25,
              child: food.image.isNotEmpty
                  ? Image.network(
                      food.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  food.name,
                  style: const TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _foodTypeBadge(food.type),
            ],
          ),
          if (isTamil) ...[
            const SizedBox(height: 7),
            Text(
              food.tamilName,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (food.category.isNotEmpty)
                _infoChip(
                  Icons.restaurant_menu_rounded,
                  food.category,
                ),
              _infoChip(
                Icons.check_circle_outline_rounded,
                food.available ? 'Available' : 'Unavailable',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('About This Food'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              food.description.trim().isNotEmpty
                  ? food.description
                  : 'Contact Nivetha Catering Service for more details '
                      'about this food item.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: AppColors.surfaceGreen,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Menu selection and catering arrangements can be '
                    'discussed while submitting your event booking.',
                    style: TextStyle(
                      color: AppColors.primaryGreenDark,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: food.available
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const BookingScreen(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.event_available_rounded),
              label: const Text('BOOK CATERING'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.disabled,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primaryGreenLight,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_rounded,
        color: AppColors.primary,
        size: 85,
      ),
    );
  }

  Widget _foodTypeBadge(String type) {
    final normalized = type.toLowerCase();
    final isNonVeg = normalized.contains('non');

    final color = isNonVeg ? AppColors.nonVeg : AppColors.veg;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: color, size: 9),
          const SizedBox(width: 6),
          Text(
            type.isEmpty ? 'Food' : type,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.primaryGreenDark,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
