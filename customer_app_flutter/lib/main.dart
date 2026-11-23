import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.lightTheme;

    return MaterialApp(
      title: 'NIVETHA CATERING SERVICES',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedInFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _RoyalSplashLoader();
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

/// Royal Crimson & Temple Gold Splash Loader while checking auth token
class _RoyalSplashLoader extends StatelessWidget {
  const _RoyalSplashLoader();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.royalHeaderGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: AppTheme.royalGold, width: 2),
                boxShadow: AppTheme.goldGlowShadow,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                size: 46,
                color: AppTheme.royalGold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NIVETHA CATERING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Authentic Feast for Every Celebration',
              style: TextStyle(
                color: AppTheme.softChampagne,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.royalGold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Navigation Shell hosting the persistent luxury bottom navigation bar.
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          border: const Border(
            top: BorderSide(color: AppTheme.borderChampagne, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCrimson.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          indicatorColor: AppTheme.royalGold.withValues(alpha: 0.24),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryCrimson),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AppTheme.primaryCrimson),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryCrimson),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryCrimson),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}