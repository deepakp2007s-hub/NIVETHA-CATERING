import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/routing/app_router.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const secureStorage = FlutterSecureStorage();
  final tokenStorage = SecureStorage(secureStorage);
  final apiClient = ApiClient(secureStorage: tokenStorage);
  final authRepository = AuthRepository(
    service: AuthService(apiClient),
    storage: tokenStorage,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(authRepository)..initialize(),
      child: const NivethaCustomerApp(),
    ),
  );
}

class NivethaCustomerApp extends StatelessWidget {
  const NivethaCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    return MaterialApp.router(
      title: 'Nivetha Catering',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: createAppRouter(authProvider),
    );
  }
}
