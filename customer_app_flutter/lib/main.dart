import 'package:flutter/material.dart';
import 'data/services/auth_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/booking/screens/create_booking_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/menu/screens/menu_screen.dart';
import 'features/my_bookings/screens/my_bookings_screen.dart';
import 'features/profile/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NivethaCateringApp());
}

class NivethaCateringApp extends StatelessWidget {
  const NivethaCateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return MaterialApp(
      title: 'Nivetha Catering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          primary: Colors.deepOrange,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
      ),
      home: FutureBuilder<bool>(
        future: authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
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
        '/home': (context) => const MainNavigationShell(),
        '/menu': (context) => const MenuScreen(),
        '/create-booking': (context) => const CreateBookingScreen(),
        '/my-bookings': (context) => const MyBookingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

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
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_outlined),
            activeIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}