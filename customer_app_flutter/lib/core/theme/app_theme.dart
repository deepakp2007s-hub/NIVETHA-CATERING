import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkForestGreen,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.luxuryGold,
        onPrimary: AppColors.darkForestGreen,
        secondary: AppColors.deepGreen,
        onSecondary: AppColors.white,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.cream,
        error: AppColors.errorRed,
      ),
      textTheme: GoogleFonts.cormorantGaramondTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.luxuryGold,
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.cream,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          color: AppColors.cream,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkForestGreen,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.luxuryGold),
        titleTextStyle: TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.luxuryGold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.luxuryGold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}