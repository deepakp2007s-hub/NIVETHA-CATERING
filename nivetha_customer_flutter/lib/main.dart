
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFF8EC),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFF8EC),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NivethaCateringApp());
}

class NivethaCateringApp extends StatelessWidget {
  const NivethaCateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nivetha Catering Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainShellScreen(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        );
      },
    );
  }
}
