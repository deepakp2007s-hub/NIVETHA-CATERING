
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/locale_provider.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToMenu;
  final VoidCallback onNavigateToBooking;

  const HomeScreen({
    super.key,
    required this.onNavigateToMenu,
    required this.onNavigateToBooking,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final categories = [
      {
        'key': 'cat_wedding',
        'icon': Icons.favorite_rounded,
        'color': const Color(0xFFB94B63),
      },
      {
        'key': 'cat_engagement',
        'icon': Icons.diamond_rounded,
        'color': const Color(0xFF8B5BA8),
      },
      {
        'key': 'cat_birthday',
        'icon': Icons.cake_rounded,
        'color': const Color(0xFFD88A26),
      },
      {
        'key': 'cat_house',
        'icon': Icons.home_rounded,
        'color': const Color(0xFF278653),
      },
      {
        'key': 'cat_corporate',
        'icon': Icons.business_center_rounded,
        'color': const Color(0xFF3977B8),
      },
      {
        'key': 'cat_college',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF218D85),
      },
      {
        'key': 'cat_temple',
        'icon': Icons.temple_hindu_rounded,
        'color': const Color(0xFFB77926),
      },
      {
        'key': 'cat_other',
        'icon': Icons.celebration_rounded,
        'color': const Color(0xFF7860AE),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(
                context,
                loc,
                localeProvider,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildHeroBanner(context, loc),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                loc.translate('event_categories'),
                'Celebrate every special moment',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = categories[index];

                    return _buildCategoryCard(
                      context,
                      loc,
                      item,
                      index,
                    );
                  },
                  childCount: categories.length,
                ),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.48,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                loc.translate('why_choose_us'),
                'Making your occasions memorable',
              ),
            ),
            SliverToBoxAdapter(
              child: _buildFeaturesSection(loc),
            ),
            SliverToBoxAdapter(
              child: _buildBottomBanner(context, loc),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations loc,
    LocaleProvider localeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryGreen,
                  AppColors.primaryGreenDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: AppColors.goldAccent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.goldAccent,
              size: 29,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('app_name'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryGreenDark,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  loc.translate('app_tagline'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Material(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: localeProvider.toggleLanguage,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.goldAccent.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      localeProvider.isTamil ? 'EN' : 'தமிழ்',
                      style: const TextStyle(
                        color: AppColors.primaryGreenDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 22),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF0C6845),
              Color(0xFF06442F),
              Color(0xFF032F22),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.goldAccent.withValues(alpha: 0.65),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreenDark.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              top: 36,
              child: Icon(
                Icons.spa_rounded,
                size: 145,
                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
            Positioned(
              right: 4,
              top: 0,
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 25,
                color: AppColors.goldAccent.withValues(alpha: 0.9),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.goldAccent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        size: 15,
                        color: AppColors.primaryGreenDark,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'SPECIAL MOMENTS • SPECIAL FOOD',
                        style: TextStyle(
                          color: AppColors.primaryGreenDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 23),
                Text(
                  loc.translate('welcome'),
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  loc.translate('hero_subtitle'),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.65,
                    color: Colors.white.withValues(alpha: 0.86),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 23),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onNavigateToBooking,
                        icon: const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                        ),
                        label: Text(
                          loc.translate('book_now'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.goldAccent,
                          foregroundColor: AppColors.primaryGreenDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onNavigateToMenu,
                        icon: const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 18,
                        ),
                        label: Text(
                          loc.translate('explore_menu'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: AppColors.goldAccent,
                      size: 17,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Thoughtful service for your special day',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.82),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 15),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.goldAccent,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    AppLocalizations loc,
    Map<String, dynamic> item,
    int index,
  ) {
    final title = loc.translate(item['key'] as String);
    final icon = item['icon'] as IconData;
    final color = item['color'] as Color;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 65)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onNavigateToBooking,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.cardBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreenDark.withValues(alpha: 0.035),
                  blurRadius: 9,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color.withValues(alpha: 0.17),
                            color.withValues(alpha: 0.07),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        size: 23,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: AppColors.goldDark,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(AppLocalizations loc) {
    final features = [
      {
        'title': loc.translate('feature_taste'),
        'subtitle': 'Delicious food for special occasions',
        'icon': Icons.restaurant_rounded,
      },
      {
        'title': loc.translate('feature_hygiene'),
        'subtitle': 'Careful preparation and cleanliness',
        'icon': Icons.verified_user_rounded,
      },
      {
        'title': loc.translate('feature_service'),
        'subtitle': 'Organised service for your event',
        'icon': Icons.support_agent_rounded,
      },
      {
        'title': loc.translate('feature_custom'),
        'subtitle': 'Menu options for your requirements',
        'icon': Icons.tune_rounded,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreenDark.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: List.generate(features.length, (index) {
          final feature = features[index];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 49,
                      height: 49,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCream,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature['subtitle'] as String,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primaryGreenLight,
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (index != features.length - 1)
                Divider(
                  height: 1,
                  color: AppColors.cardBorder.withValues(alpha: 0.8),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBottomBanner(
    BuildContext context,
    AppLocalizations loc,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: AppColors.surfaceCream,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.goldAccent.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: AppColors.goldAccent,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planning a celebration?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Let us help you plan your catering.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNavigateToBooking,
            tooltip: 'Start booking',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.goldAccent,
              foregroundColor: AppColors.primaryGreenDark,
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}
