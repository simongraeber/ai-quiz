import 'package:flutter/material.dart';

// to add a language, add the language to l10n.yaml and create a new file in the
// l10n folder then add the language code and the flag below

/// this class is to represent the language codes and the flags
/// for lateralization
class L10n {
  static final all = [
    const Locale('en'),
    const Locale('de'),
  ];

  static String getFlag(String code) {
    switch (code) {
      case 'de':
        return '🇩🇪';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}

/// this Notifier is used to change the language of the app
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if(!L10n.all.contains(locale)) {
      return;
    }
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}