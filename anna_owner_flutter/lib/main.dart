import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/services/auth_service.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorage = SecureStorage();

  final apiClient = ApiClient(
    secureStorage: secureStorage,
  );

  final authService = AuthService(
    apiClient: apiClient,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            secureStorage: secureStorage,
          )..initialize(),
        ),
      ],
      child: const AnnaOwnerApp(),
    ),
  );
}

class AnnaOwnerApp extends StatelessWidget {
  const AnnaOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nivetha Anna Owner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          if (auth.isInitializing) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (auth.isAuthenticated) {
            return const DashboardScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}