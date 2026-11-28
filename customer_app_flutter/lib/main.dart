import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/notification_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/booking/screens/create_booking_screen.dart';
import 'features/foods/screens/foods_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/menu/screens/menu_screen.dart';
import 'features/my_bookings/screens/my_bookings_screen.dart';
import 'features/profile/screens/profile_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.initialize(rootNavigatorKey);
  } catch (e) {
    debugPrint('FIREBASE_OR_NOTIFICATION_INIT_ERROR: $e');
  }
  runApp(const NivethaCateringApp());
}

enum _StartDestination {
  home,
  register,
  login,
}

/// Root Application Widget for NIVETHA Customer App.
class NivethaCateringApp extends StatefulWidget {
  const NivethaCateringApp({super.key});

  @override
  State<NivethaCateringApp> createState() => _NivethaCateringAppState();
}

class _NivethaCateringAppState extends State<NivethaCateringApp> {
  static const String _installedFlagKey = 'has_installed_before';
  static const Color _forestEmerald = Color(0xFF144536);
  static const Color _champagneGold = Color(0xFFD9A441);

  final AuthService _authService = AuthService();
  late final Future<_StartDestination> _startDestinationFuture;

  @override
  void initState() {
    super.initState();
    _startDestinationFuture = _resolveStartDestination();
  }

  Future<_StartDestination> _resolveStartDestination() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await NotificationService.instance.syncTokenWithBackend();
      return _StartDestination.home;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasInstalledBefore = prefs.getBool(_installedFlagKey) ?? false;

    if (!hasInstalledBefore) {
      await prefs.setBool(_installedFlagKey, true);
      return _StartDestination.register;
    }

    return _StartDestination.login;
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.lightTheme;

    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'NIVETHA CATERING SERVICES',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        colorScheme: baseTheme.colorScheme.copyWith(
          primary: _forestEmerald,
          secondary: _champagneGold,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
      ),
      home: FutureBuilder<_StartDestination>(
        future: _startDestinationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _EmeraldSplashLoader();
          }
          switch (snapshot.data) {
            case _StartDestination.home:
              return const MainNavigationShell();
            case _StartDestination.login:
              return const LoginScreen();
            case _StartDestination.register:
            default:
              return const RegisterScreen();
          }
        },
      ),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
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

/// Forest Emerald & Champagne Gold Splash Loader while checking auth token.
class _EmeraldSplashLoader extends StatelessWidget {
  const _EmeraldSplashLoader();

  static const Color _forestEmerald = Color(0xFF144536);
  static const Color _deepForest = Color(0xFF0C2E24);
  static const Color _emeraldMid = Color(0xFF1E634D);
  static const Color _champagneGold = Color(0xFFD9A441);
  static const Color _softChampagne = Color(0xFFF6E7C1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_forestEmerald, _emeraldMid],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _deepForest.withValues(alpha: 0.55),
                border: Border.all(color: _champagneGold, width: 2),
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                size: 46,
                color: _champagneGold,
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
              'Warm Feasts Crafted For Your Special Day',
              style: TextStyle(
                color: _softChampagne,
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
                valueColor: AlwaysStoppedAnimation<Color>(_champagneGold),
              ),
            ),
          ],
        ),
      ),
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
  static const Color _forestEmerald = Color(0xFF144536);
  static const Color _deepForest = Color(0xFF0C2E24);
  static const Color _champagneGold = Color(0xFFD9A441);
  static const Color _warmSandBorder = Color(0xFFE5DEC9);

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
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: _warmSandBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: _deepForest.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: _champagneGold.withValues(alpha: 0.25),
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: _forestEmerald),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(
                Icons.restaurant_menu_rounded,
                color: _forestEmerald,
              ),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(
                Icons.calendar_month_rounded,
                color: _forestEmerald,
              ),
              label: 'Bookings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: _forestEmerald),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}