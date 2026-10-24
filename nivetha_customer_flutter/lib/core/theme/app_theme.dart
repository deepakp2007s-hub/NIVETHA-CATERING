import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color navy = Color(0xFF102541);
  static const Color navyLight = Color(0xFF294D70);
  static const Color gold = Color(0xFFD9A441);
  static const Color goldLight = Color(0xFFFFE6A2);
  static const Color cream = Color(0xFFFFF8EC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF102541);
  static const Color textSecondary = Color(0xFF718096);
  static const Color success = Color(0xFF21865B);
  static const Color error = Color(0xFFC54646);
  static const Color border = Color(0xFFECE3D5);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: navy,
      secondary: gold,
      surface: surface,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: cream,
      primaryColor: navy,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: navy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: navy,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(color: navy),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: navy,
          fontSize: 34,
          fontWeight: FontWeight.w900,
        ),
        displayMedium: TextStyle(
          color: navy,
          fontSize: 29,
          fontWeight: FontWeight.w900,
        ),
        headlineLarge: TextStyle(
          color: navy,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: navy,
          fontSize: 21,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: navy,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: navy,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 13,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 11,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          color: navy,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        labelMedium: TextStyle(
          color: navy,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          color: textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blueGrey.shade200,
          elevation: 3,
          shadowColor: navy.withValues(alpha: 0.18),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          minimumSize: const Size(0, 50),
          side: const BorderSide(color: gold, width: 1.2),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: navy,
          textStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA5B4),
          fontSize: 12,
        ),
        prefixIconColor: navyLight,
        suffixIconColor: navyLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: navy.withValues(alpha: 0.07),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 0.6),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: goldLight,
        disabledColor: const Color(0xFFE9E9E9),
        labelStyle: const TextStyle(
          color: navy,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: navy,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: const BorderSide(color: border),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: navy,
        unselectedItemColor: textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: goldLight,
        elevation: 5,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            color: selected ? navy : textSecondary,
            fontSize: 10,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          final selected = states.contains(WidgetState.selected);

          return IconThemeData(
            color: selected ? navy : textSecondary,
            size: selected ? 24 : 22,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: navy,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cream,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          color: navy,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 13,
          height: 1.5,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navy,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: navy,
        textColor: navy,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? navy
              : Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: gold, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected) ? gold : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected)
              ? navy.withValues(alpha: 0.8)
              : Colors.blueGrey.shade200;
        }),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          navy.withValues(alpha: 0.25),
        ),
        radius: const Radius.circular(10),
        thickness: WidgetStateProperty.all(4),
      ),
    );
  }
}
