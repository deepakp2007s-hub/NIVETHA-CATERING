import 'package:flutter/material.dart';
class AppTheme {
  AppTheme._();
  static const Color _deepGreen = Color(0xFF064E35);
  static const Color _primaryGreen = Color(0xFF086443);
  static const Color _gold = Color(0xFFFFC928);
  static const Color _cream = Color(0xFFFFF9E9);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _textDark = Color(0xFF17231D);
  static const Color _textMuted = Color(0xFF68756D);
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryGreen,
      brightness: Brightness.light,
      primary: _primaryGreen,
      onPrimary: Colors.white,
      secondary: _gold,
      onSecondary: _deepGreen,
      surface: _cardWhite,
      onSurface: _textDark,
      error: const Color(0xFFB3261E),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _cream,
      fontFamily: null,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: const AppBarTheme(
        backgroundColor: _deepGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        color: _cardWhite,
        elevation: 3,
        shadowColor: _deepGreen.withValues(alpha: 0.10),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: _primaryGreen.withValues(alpha: 0.09),
            width: 1,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB8C7BE),
          disabledForegroundColor: Colors.white70,
          elevation: 3,
          shadowColor: _deepGreen.withValues(alpha: 0.22),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 17,
          ),
          minimumSize: const Size(0, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryGreen,
          side: const BorderSide(
            color: _primaryGreen,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 16,
          ),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryGreen,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(
          color: _textMuted,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: _textMuted,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE2E9E2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE2E9E2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _primaryGreen,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFB3261E),
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _primaryGreen.withValues(alpha: 0.12),
        elevation: 8,
        height: 76,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? _primaryGreen : _textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);

          return IconThemeData(
            size: selected ? 25 : 23,
            color: selected ? _primaryGreen : _textMuted,
          );
        }),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: _primaryGreen.withValues(alpha: 0.12),
        disabledColor: const Color(0xFFE9ECE9),
        side: BorderSide(
          color: _primaryGreen.withValues(alpha: 0.12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        labelStyle: const TextStyle(
          color: _textDark,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        secondaryLabelStyle: const TextStyle(
          color: _primaryGreen,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 7,
          vertical: 5,
        ),
      ),

      dividerTheme: DividerThemeData(
        color: _primaryGreen.withValues(alpha: 0.10),
        thickness: 1,
        space: 24,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryGreen,
        linearTrackColor: Color(0xFFE4EDE5),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _deepGreen,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _gold,
        foregroundColor: _deepGreen,
        elevation: 5,
      ),
    );
  }
}