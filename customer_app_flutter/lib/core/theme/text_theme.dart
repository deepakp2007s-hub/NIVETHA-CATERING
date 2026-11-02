import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTextTheme {
  static TextTheme get darkTextTheme {
    return TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.luxuryGold,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: AppColors.cream,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.luxuryGold,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.bold,
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
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.darkForestGreen,
      ),
    );
  }
}