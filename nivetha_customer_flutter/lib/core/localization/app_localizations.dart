import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'Nivetha Catering',
      'app_tagline': 'Authentic Flavors for Every Celebration',
      'home': 'Home',
      'menu': 'Menu',
      'bookings': 'Bookings',
      'profile': 'Profile',
      'welcome': 'Welcome to Nivetha Catering',
      'hero_subtitle': 'Premium South Indian & Multi-Cuisine Catering for all your life milestones.',
      'book_now': 'Book a Feast',
      'explore_menu': 'Explore Menu',
      'event_categories': 'Select Your Event',
      'why_choose_us': 'Why Choose Nivetha Catering',
      'feature_taste': 'Authentic Traditional Taste',
      'feature_hygiene': '100% Hygienic Preparation',
      'feature_service': 'Punctual & Hospitable Service',
      'feature_custom': 'Tailor-Made Custom Menus',
      'call_us': 'Call for Inquiries',
      'cat_wedding': 'Wedding',
      'cat_engagement': 'Engagement',
      'cat_birthday': 'Birthday',
      'cat_house': 'House Function',
      'cat_corporate': 'Corporate Event',
      'cat_college': 'College / School Event',
      'cat_temple': 'Temple Function',
      'cat_other': 'Other Events',
    },
    'ta': {
      'app_name': 'நிவேதா கேட்டரிங்',
      'app_tagline': 'உங்கள் இல்ல விசேஷங்களுக்கு சுவையான விருந்து',
      'home': 'முகப்பு',
      'menu': 'உணவு பட்டியல்',
      'bookings': 'முன்பதிவுகள்',
      'profile': 'சுயவிவரம்',
      'welcome': 'நிவேதா கேட்டரிங்-க்கு நல்வரவு',
      'hero_subtitle': 'உங்களின் அனைத்து சுப நிகழ்வுகளுக்கும் பாரம்பரிய மற்றும் தரமான அறுசுவை உணவு உபசரிப்பு.',
      'book_now': 'முன்பதிவு செய்ய',
      'explore_menu': 'உணவு பட்டியல் பார்க்க',
      'event_categories': 'நிகழ்வை தேர்ந்தெடுக்கவும்',
      'why_choose_us': 'எங்களை ஏன் தேர்ந்தெடுக்க வேண்டும்?',
      'feature_taste': 'அசல் பாரம்பரிய சுவை',
      'feature_hygiene': '100% தூய்மையான தயாரிப்பு',
      'feature_service': 'நேர தவறாமை & கனிவான உபசரிப்பு',
      'feature_custom': 'விருப்பத்திற்கேற்ப மெனு அமைப்பு',
      'call_us': 'தொடர்பு கொள்ள',
      'cat_wedding': 'திருமணம்',
      'cat_engagement': 'நிச்சயதார்த்தம்',
      'cat_birthday': 'பிறந்தநாள்',
      'cat_house': 'வீட்டு விசேஷம்',
      'cat_corporate': 'நிறுவன நிகழ்வு',
      'cat_college': 'பள்ளி / கல்லூரி விழா',
      'cat_temple': 'கோவில் திருவிழா',
      'cat_other': 'இதர நிகழ்வுகள்',
    },
  };
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'ta'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}