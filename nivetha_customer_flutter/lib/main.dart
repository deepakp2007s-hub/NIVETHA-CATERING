
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/booking/booking_screen.dart';
import 'presentation/screens/main_shell_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFFF8ED),
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFF8ED),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const NivethaCustomerApp());
}

class NivethaCustomerApp extends StatelessWidget {
  const NivethaCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Nivetha Catering Service',
            debugShowCheckedModeBanner: false,

            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,

            locale: localeProvider.locale,

            supportedLocales: const [
              Locale('en'),
              Locale('ta'),
            ],

            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            initialRoute: '/',

            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const MainShellScreen(),
              '/booking': (context) => const BookingScreen(),
            },

            onUnknownRoute: (settings) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const LoginScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
