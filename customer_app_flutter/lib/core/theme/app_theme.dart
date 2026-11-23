import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 1. Royal South Indian Luxury Catering Palette
  static const Color primaryCrimson = Color(0xFF7A121C);     // Deep Royal Crimson
  static const Color primaryRichRed = Color(0xFFA61C2B);     // Vibrant Festivity Red
  static const Color primaryDeepWine = Color(0xFF4D080F);    // Dark Wine Shadow Tone
  
  static const Color royalGold = Color(0xFFD4AF37);          // Antique Temple Gold
  static const Color warmSaffron = Color(0xFFF39C12);        // Bright Saffron Highlight
  static const Color softChampagne = Color(0xFFF6E7C1);      // Light Gold Glow

  // 2. Warm App Surfaces (Makes food photos look vibrant & appetizing)
  static const Color backgroundSandal = Color(0xFFFDFBF7);   // Warm Sandalwood Cream
  static const Color surfaceWhite = Color(0xFFFFFFFF);       // Pure Crisp Card Surface
  static const Color surfaceTint = Color(0xFFF7F1E8);        // Soft Warm Accent Surface

  // 3. Typography & Borders
  static const Color textEspresso = Color(0xFF231917);       // Deep Espresso
  static const Color textMuted = Color(0xFF6E625D);          // Warm Taupe Grey
  static const Color borderChampagne = Color(0xFFE8DFD3);    // Subtle Champagne Border

  // 4. Semantic & Dietary Colors
  static const Color bananaLeafGreen = Color(0xFF1B7A43);    // Pure Veg / Confirmed
  static const Color marigoldAmber = Color(0xFFE67E22);      // Pending / Warm Notice
  static const Color spiceRed = Color(0xFFC0392B);           // Non-Veg / Error
  static const Color royalTeal = Color(0xFF117A8B);          // Completed / Info

  // 5. Ready-to-Use Luxury Gradients (Use in Headers, Banners & Special Buttons)
  static const LinearGradient royalHeaderGradient = LinearGradient(
    colors: [primaryDeepWine, primaryCrimson, primaryRichRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldAccentGradient = LinearGradient(
    colors: [royalGold, warmSaffron],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient foodImageOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1A090B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 6. Soft Luxury Box Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryCrimson.withValues(alpha: 0.07),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get goldGlowShadow => [
        BoxShadow(
          color: royalGold.withValues(alpha: 0.28),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  // 7. Main Light Theme
  static ThemeData get lightTheme {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryCrimson,
      primary: primaryCrimson,
      onPrimary: Colors.white,
      secondary: royalGold,
      onSecondary: textEspresso,
      tertiary: bananaLeafGreen,
      surface: surfaceWhite,
      onSurface: textEspresso,
      error: spiceRed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundSandal,

      // Status Bar & AppBar Styling
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryCrimson,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
        iconTheme: IconThemeData(color: royalGold, size: 24),
      ),

      // Elevated Card Styling
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 3,
        shadowColor: primaryCrimson.withValues(alpha: 0.10),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderChampagne, width: 1.0),
        ),
      ),

      // Primary Action Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCrimson,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryCrimson.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Outlined Gold-Trimmed Buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCrimson,
          side: const BorderSide(color: royalGold, width: 1.6),
          backgroundColor: surfaceTint.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryCrimson,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Clean Form Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderChampagne),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderChampagne, width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryCrimson, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: spiceRed, width: 1.4),
        ),
        prefixIconColor: primaryCrimson,
        suffixIconColor: textMuted,
        labelStyle: const TextStyle(color: textMuted, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      ),

      // Category Filter Chips
      chipTheme: ChipThemeData(
        backgroundColor: surfaceTint,
        selectedColor: primaryCrimson,
        disabledColor: Colors.grey.shade200,
        labelStyle: const TextStyle(
          color: textEspresso,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: royalGold,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: borderChampagne),
        ),
      ),

      // Material 3 Bottom Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        elevation: 12,
        height: 70,
        shadowColor: primaryCrimson.withValues(alpha: 0.15),
        indicatorColor: royalGold.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryCrimson,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryCrimson, size: 25);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
      ),

      // Clean Divider
      dividerTheme: const DividerThemeData(
        color: borderChampagne,
        thickness: 1,
        space: 24,
      ),

      // Typography Hierarchy
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textEspresso,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textEspresso,
          fontSize: 23,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: textEspresso,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textEspresso,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textEspresso,
          fontSize: 15,
          height: 1.4,
        ),
        bodyMedium: TextStyle(
          color: textMuted,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}