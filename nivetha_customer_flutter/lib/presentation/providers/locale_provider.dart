
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  bool get isTamil => _locale.languageCode == 'ta';

  bool get isEnglish => _locale.languageCode == 'en';

  String get languageName => isTamil ? 'தமிழ்' : 'English';

  void setLocale(Locale locale) {
    if (locale.languageCode != 'en' && locale.languageCode != 'ta') {
      return;
    }

    if (_locale.languageCode == locale.languageCode) {
      return;
    }

    _locale = Locale(locale.languageCode);
    notifyListeners();
  }

  void setEnglish() {
    setLocale(const Locale('en'));
  }

  void setTamil() {
    setLocale(const Locale('ta'));
  }

  void toggleLanguage() {
    setLocale(
      isEnglish ? const Locale('ta') : const Locale('en'),
    );
  }
}
