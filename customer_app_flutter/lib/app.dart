import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/localization/locale_provider.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_router.dart';

class NivethaCateringApp extends StatelessWidget {
  const NivethaCateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Nivetha Catering',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: AppColors.backgroundDark,
              primaryColor: AppColors.luxuryGold,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.luxuryGold,
                secondary: AppColors.deepGreen,
                surface: AppColors.surfaceDark,
                error: AppColors.errorRed,
              ),
            ),
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ta', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
            ],
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}