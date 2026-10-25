
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color cream = Color(0xFFFFF8ED);
  static const Color darkBrown = Color(0xFF402719);
  static const Color brown = Color(0xFF765039);
  static const Color gold = Color(0xFFD5A64A);
  static const Color lightGold = Color(0xFFF5E5C2);
  static const Color white = Colors.white;
  static const Color success = Color(0xFF557A46);
  static const Color error = Color(0xFFB83A3A);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkBrown,
      brightness: Brightness.light,
      primary: darkBrown,
      secondary: gold,
      surface: white,
      error: error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: cream,
      fontFamily: 'Roboto',

      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: darkBrown,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: darkBrown,
          fontSize: 21,
          fontWeight: FontWeight.w900,
        ),
        iconTheme: IconThemeData(
          color: darkBrown,
          size: 24,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: darkBrown,
          fontSize: 32,
          fontWeight: FontWeight.w900,
        ),
        displayMedium: TextStyle(
          color: darkBrown,
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
        displaySmall: TextStyle(
          color: darkBrown,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        headlineLarge: TextStyle(
          color: darkBrown,
          fontSize: 23,
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: darkBrown,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        headlineSmall: TextStyle(
          color: darkBrown,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: darkBrown,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: darkBrown,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: brown,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: darkBrown,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: brown,
          fontSize: 13,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: brown,
          fontSize: 11,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: darkBrown,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
        labelMedium: TextStyle(
          color: brown,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        labelSmall: TextStyle(
          color: brown,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBrown,
          foregroundColor: white,
          disabledBackgroundColor: lightGold,
          disabledForegroundColor: brown,
          elevation: 0,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 14,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkBrown,
          side: const BorderSide(
            color: gold,
            width: 1.2,
          ),
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 13,
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkBrown,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: brown.withValues(alpha: 0.55),
          fontSize: 13,
        ),
        labelStyle: const TextStyle(
          color: brown,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: brown,
        suffixIconColor: brown,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: lightGold,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: lightGold,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: gold,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: error,
            width: 1.5,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: lightGold,
            width: 1,
          ),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: darkBrown,
        unselectedItemColor: brown,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      dividerTheme: const DividerThemeData(
        color: lightGold,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: white,
        selectedColor: lightGold,
        disabledColor: cream,
        secondarySelectedColor: lightGold,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        labelStyle: const TextStyle(
          color: darkBrown,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        secondaryLabelStyle: const TextStyle(
          color: darkBrown,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: lightGold,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkBrown,
        foregroundColor: gold,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(17),
          ),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: gold,
        linearTrackColor: lightGold,
        circularTrackColor: lightGold,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBrown;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(white),
        side: const BorderSide(
          color: gold,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBrown;
          }
          return brown;
        }),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return gold;
          }
          return Colors.grey.shade300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBrown;
          }
          return Colors.grey.shade200;
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cream,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titleTextStyle: const TextStyle(
          color: darkBrown,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        contentTextStyle: const TextStyle(
          color: brown,
          fontSize: 13,
          height: 1.5,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBrown,
        contentTextStyle: const TextStyle(
          color: white,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: darkBrown,
        textColor: darkBrown,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: lightGold,
          ),
        ),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: cream,
        headerBackgroundColor: darkBrown,
        headerForegroundColor: white,
        todayForegroundColor: WidgetStateProperty.all(darkBrown),
        todayBorder: const BorderSide(color: gold),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return white;
          }
          return darkBrown;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkBrown;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: cream,
        dialBackgroundColor: lightGold,
        dialHandColor: darkBrown,
        hourMinuteColor: lightGold,
        hourMinuteTextColor: darkBrown,
        dayPeriodColor: lightGold,
        dayPeriodTextColor: darkBrown,
        entryModeIconColor: darkBrown,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),

      iconTheme: const IconThemeData(
        color: darkBrown,
        size: 22,
      ),

      splashFactory: InkRipple.splashFactory,
    );
  }
}
