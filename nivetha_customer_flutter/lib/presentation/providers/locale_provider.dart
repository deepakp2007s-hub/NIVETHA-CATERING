
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isTamil => _locale.languageCode == 'ta';

  String get languageName => isTamil ? 'தமிழ்' : 'English';

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' &&
        locale.languageCode != 'ta') {
      return;
    }

    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();
  }

  void setEnglish() {
    setLocale(const Locale('en'));
  }

  void setTamil() {
    setLocale(const Locale('ta'));
  }

  void toggleLanguage() {
    if (isTamil) {
      setEnglish();
    } else {
      setTamil();
    }
  }
}
