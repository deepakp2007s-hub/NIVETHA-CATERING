
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );

    assert(
      result != null,
      'AppLocalizations is not available in this context. '
      'Add AppLocalizations.delegate to MaterialApp.localizationsDelegates.',
    );

    return result!;
  }

  bool get isTamil => locale.languageCode == 'ta';

  String _text(String englishText, String tamilText) {
    return isTamil ? tamilText : englishText;
  }

  String get appName => _text(
        'Nivetha Catering',
        'நிவேதா கேட்டரிங்',
      );

  String get welcome => _text(
        'Welcome',
        'வரவேற்கிறோம்',
      );

  String get login => _text(
        'Login',
        'உள்நுழைய',
      );

  String get register => _text(
        'Register',
        'பதிவு செய்ய',
      );

  String get logout => _text(
        'Logout',
        'வெளியேறு',
      );

  String get home => _text(
        'Home',
        'முகப்பு',
      );

  String get foodMenu => _text(
        'Food Menu',
        'உணவுப் பட்டியல்',
      );

  String get bookService => _text(
        'Book Service',
        'சேவையை முன்பதிவு செய்',
      );

  String get myBookings => _text(
        'My Bookings',
        'எனது முன்பதிவுகள்',
      );

  String get notifications => _text(
        'Notifications',
        'அறிவிப்புகள்',
      );

  String get profile => _text(
        'Profile',
        'சுயவிவரம்',
      );

  String get fullName => _text(
        'Full Name',
        'முழுப் பெயர்',
      );

  String get mobileNumber => _text(
        'Mobile Number',
        'கைபேசி எண்',
      );

  String get email => _text(
        'Email Address',
        'மின்னஞ்சல் முகவரி',
      );

  String get password => _text(
        'Password',
        'கடவுச்சொல்',
      );

  String get confirmPassword => _text(
        'Confirm Password',
        'கடவுச்சொல்லை உறுதிப்படுத்து',
      );

  String get functionDate => _text(
        'Function Date',
        'நிகழ்ச்சி தேதி',
      );

  String get functionTime => _text(
        'Function Time',
        'நிகழ்ச்சி நேரம்',
      );

  String get location => _text(
        'Location',
        'இடம்',
      );

  String get numberOfPersons => _text(
        'Number of Persons',
        'நபர்களின் எண்ணிக்கை',
      );

  String get foodPreference => _text(
        'Food Preference',
        'உணவு விருப்பம்',
      );

  String get vegetarian => _text(
        'Vegetarian',
        'சைவம்',
      );

  String get nonVegetarian => _text(
        'Non-Vegetarian',
        'அசைவம்',
      );

  String get breakfast => _text(
        'Breakfast',
        'காலை உணவு',
      );

  String get lunch => _text(
        'Lunch',
        'மதிய உணவு',
      );

  String get dinner => _text(
        'Dinner',
        'இரவு உணவு',
      );

  String get submit => _text(
        'Submit',
        'சமர்ப்பிக்க',
      );

  String get cancel => _text(
        'Cancel',
        'ரத்து செய்',
      );

  String get save => _text(
        'Save',
        'சேமி',
      );

  String get retry => _text(
        'Retry',
        'மீண்டும் முயற்சி செய்',
      );

  String get loading => _text(
        'Loading...',
        'ஏற்றப்படுகிறது...',
      );

  String get noBookings => _text(
        'No bookings found',
        'முன்பதிவுகள் எதுவும் இல்லை',
      );

  String get noNotifications => _text(
        'No notifications',
        'அறிவிப்புகள் எதுவும் இல்லை',
      );

  String get language => _text(
        'Language',
        'மொழி',
      );

  String get english => _text(
        'English',
        'ஆங்கிலம்',
      );

  String get tamil => _text(
        'Tamil',
        'தமிழ்',
      );

  String get search => _text(
        'Search',
        'தேடு',
      );

  String get settings => _text(
        'Settings',
        'அமைப்புகள்',
      );

  String get editProfile => _text(
        'Edit Profile',
        'சுயவிவரத்தைத் திருத்து',
      );

  String get updateProfile => _text(
        'Update Profile',
        'சுயவிவரத்தைப் புதுப்பி',
      );

  String get bookingDetails => _text(
        'Booking Details',
        'முன்பதிவு விவரங்கள்',
      );

  String get bookingStatus => _text(
        'Booking Status',
        'முன்பதிவு நிலை',
      );

  String get pending => _text(
        'Pending',
        'நிலுவையில்',
      );

  String get confirmed => _text(
        'Confirmed',
        'உறுதிப்படுத்தப்பட்டது',
      );

  String get completed => _text(
        'Completed',
        'நிறைவடைந்தது',
      );

  String get rejected => _text(
        'Rejected',
        'நிராகரிக்கப்பட்டது',
      );

  String get cancelled => _text(
        'Cancelled',
        'ரத்து செய்யப்பட்டது',
      );

  String get specialRequirements => _text(
        'Special Requirements',
        'சிறப்பு தேவைகள்',
      );

  String get selectDate => _text(
        'Select Date',
        'தேதியைத் தேர்ந்தெடுக்கவும்',
      );

  String get selectTime => _text(
        'Select Time',
        'நேரத்தைத் தேர்ந்தெடுக்கவும்',
      );

  String get selectFood => _text(
        'Select Food',
        'உணவைத் தேர்ந்தெடுக்கவும்',
      );

  String get confirm => _text(
        'Confirm',
        'உறுதிப்படுத்து',
      );

  String get continueText => _text(
        'Continue',
        'தொடரவும்',
      );

  String get back => _text(
        'Back',
        'பின்னால்',
      );

  String get done => _text(
        'Done',
        'முடிந்தது',
      );

  String get error => _text(
        'Something went wrong',
        'ஏதோ தவறு ஏற்பட்டுள்ளது',
      );

  String get networkError => _text(
        'Unable to connect to the server. Please try again.',
        'சேவையகத்துடன் இணைக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
      );

  String get loginRequired => _text(
        'Please log in to continue.',
        'தொடர உள்நுழையவும்.',
      );
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(locale),
    );
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) {
    return false;
  }
}
