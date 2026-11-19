import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/services/auth_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/booking/screens/create_booking_screen.dart';
import 'features/foods/screens/foods_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/menu/screens/menu_screen.dart';
import 'features/my_bookings/screens/my_bookings_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NivethaCateringApp());
}

/// Root Application Widget for NIVETHA Customer App.
class NivethaCateringApp extends StatefulWidget {
  const NivethaCateringApp({super.key});

  @override
  State<NivethaCateringApp> createState() => _NivethaCateringAppState();
}

class _NivethaCateringAppState extends State<NivethaCateringApp> {
  final AuthService _authService = AuthService();
  late final Future<bool> _isLoggedInFuture;

  // Primary Brand Palette: Authentic Terracotta Saffron & Amber
  static const Color _primaryColor = Color(0xFFC85A17);
  static const Color _primaryDark = Color(0xFF9E3E07);
  static const Color _secondaryColor = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nivetha Catering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          primary: _primaryColor,
          secondary: _secondaryColor,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _primaryDark,
            side: const BorderSide(color: _primaryColor, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 1.8),
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedInFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                ),
              ),
            );
          }
          if (snapshot.data == true) {
            return const MainNavigationShell();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = args is int ? args.clamp(0, 3) : 0;
          return MainNavigationShell(initialIndex: initialIndex);
        },
        '/menu': (context) => const MenuScreen(),
        '/foods': (context) => const FoodsScreen(),
        '/create-booking': (context) => const CreateBookingScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

/// Navigation Shell hosting the persistent bottom navigation bar.
class MainNavigationShell extends StatefulWidget {
  final int initialIndex;
  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    MenuScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: primaryColor.withValues(alpha: 0.16),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: primaryColor),
            label: 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded, color: primaryColor),
            label: 'Menu',
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: primaryColor),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}