
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF402719);
  static const Color primaryDark = Color(0xFF2E1B12);
  static const Color primaryLight = Color(0xFF765039);

  // Legacy green aliases for existing widgets
  static const Color primaryGreen = primary;
  static const Color primaryGreenDark = primaryDark;
  static const Color primaryGreenLight = Color(0xFFF5E5C2);

  // Gold colors
  static const Color secondary = Color(0xFFD5A64A);
  static const Color gold = Color(0xFFD5A64A);
  static const Color goldAccent = gold;
  static const Color goldLight = Color(0xFFF5E5C2);
  static const Color goldDark = Color(0xFFAC7D25);
  static const Color darkGold = goldDark;
  static const Color accent = Color(0xFFFFE6A2);

  // Background colors
  static const Color background = Color(0xFFFFF8ED);
  static const Color backgroundLight = Color(0xFFFFFCF6);
  static const Color surface = Colors.white;
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceCream = Color(0xFFFFF8ED);
  static const Color surfaceGreen = Color(0xFFF5E5C2);
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF302218);
  static const Color textSecondary = Color(0xFF786B60);
  static const Color textLight = Color(0xFFA69A8E);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnGold = Color(0xFF302218);

  // Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFED8B00);
  static const Color warningLight = Color(0xFFFFF4DF);

  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);

  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Food type colors
  static const Color veg = Color(0xFF23834D);
  static const Color nonVeg = Color(0xFFD32F2F);

  // Booking status colors
  static const Color pending = Color(0xFFED8B00);
  static const Color confirmed = Color(0xFF2E7D32);
  static const Color rejected = Color(0xFFC62828);
  static const Color cancelled = Color(0xFF757575);
  static const Color completed = Color(0xFF1565C0);

  // Borders and UI elements
  static const Color divider = Color(0xFFE8DED0);
  static const Color border = Color(0xFFE8DED0);
  static const Color borderLight = Color(0xFFF2EADF);
  static const Color cardBorder = Color(0xFFE8DED0);

  static const Color disabled = Color(0xFFBDB5AC);
  static const Color icon = Color(0xFF786B60);
  static const Color shimmer = Color(0xFFEEEEEE);

  // Common colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Navigation colors
  static const Color navigationBackground = Colors.white;
  static const Color navigationSelected = primary;
  static const Color navigationUnselected = Color(0xFF9A8F84);

  // Overlay and shadow
  static const Color overlay = Color(0x66000000);
  static const Color shadow = Color(0x1F402719);

  // Brand gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      primary,
      primaryLight,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gold gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      goldLight,
      gold,
      goldDark,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      backgroundLight,
      background,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
