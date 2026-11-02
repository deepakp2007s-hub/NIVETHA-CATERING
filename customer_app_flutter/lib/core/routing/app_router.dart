import 'package:flutter/material.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainNav = '/main-nav';
  static const String menuDetail = '/menu-detail';
  static const String bookingCreate = '/booking-create';
  static const String bookingDetail = '/booking-detail';
  static const String profileEdit = '/profile-edit';
  static const String addressList = '/address-list';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Splash Screen')),
          ),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Login Screen')),
          ),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Register Screen')),
          ),
          settings: settings,
        );
      case mainNav:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Main Navigation Screen')),
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}