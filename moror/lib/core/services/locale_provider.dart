import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale_code';
  
  Locale _locale = const Locale('ar', 'SD');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  String get languageCode => _locale.languageCode;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_localeKey) ?? 'ar';
      if (code == 'en') {
        _locale = const Locale('en', 'US');
      } else {
        _locale = const Locale('ar', 'SD');
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('ar', 'SD');
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    if (isArabic) {
      await setLocale('en');
    } else {
      await setLocale('ar');
    }
  }
}
