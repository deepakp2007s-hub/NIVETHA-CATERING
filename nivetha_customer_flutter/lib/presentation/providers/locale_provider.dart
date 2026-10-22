import 'package:flutter/material.dart';
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool get isTamil => _locale.languageCode == 'ta';
  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      notifyListeners();
    }
  }
  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      _locale = const Locale('ta');
    } else {
      _locale = const Locale('en');
    }
    notifyListeners();
  }
}