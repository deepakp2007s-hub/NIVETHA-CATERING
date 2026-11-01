import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/splash/screens/splash_screen.dart';

GoRouter createAppRouter(AuthProvider auth) => GoRouter(
      initialLocation: '/splash',
      refreshListenable: auth,
      redirect: (context, state) {
        final path = state.matchedLocation;
        if (auth.isInitializing) return path == '/splash' ? null : '/splash';
        if (!auth.isAuthenticated) {
          return path == '/register' ? null : (path == '/login' ? null : '/login');
        }
        if (path == '/splash' || path == '/login' || path == '/register') {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(
          path: '/home',
          builder: (_, _) => const HomeScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text(state.error?.toString() ?? 'Page not found')),
      ),
    );

extension AuthNavigation on BuildContext {
  AuthProvider get auth => read<AuthProvider>();
}
