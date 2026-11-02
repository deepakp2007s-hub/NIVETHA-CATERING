import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Nivetha Catering',
      'home': 'Home',
      'menu': 'Menu',
      'bookings': 'Bookings',
      'favorites': 'Favorites',
      'profile': 'Profile',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'tryAgain': 'Try Again',
      'loading': 'Loading...',
      'error': 'Something went wrong',
    },
    'ta': {
      'appName': 'நிவேதா கேட்டரிங்',
      'home': 'முகப்பு',
      'menu': 'உணவு பட்டியல்',
      'bookings': 'முன்பதிவுகள்',
      'favorites': 'விருப்பமானவை',
      'profile': 'சுயவிவரம்',
      'login': 'உள்நுழைக',
      'register': 'பதிவு செய்க',
      'logout': 'வெளியேறு',
      'tryAgain': 'மீண்டும் முயற்சிக்கவும்',
      'loading': 'ஏற்றுகிறது...',
      'error': 'ஏதோ தவறு நடந்துள்ளது',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}