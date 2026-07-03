import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class AppSettings extends ChangeNotifier {
  AppSettings._();

  static final AppSettings instance = AppSettings._();

  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale_code';

  AppThemeMode _themeMode = AppThemeMode.system;
  Locale _locale = const Locale('tr', 'TR');
  bool _loaded = false;

  AppThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isLoaded => _loaded;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get localeTag =>
      _locale.countryCode == null || _locale.countryCode!.isEmpty
          ? _locale.languageCode
          : '${_locale.languageCode}_${_locale.countryCode}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < AppThemeMode.values.length) {
      _themeMode = AppThemeMode.values[themeIndex];
    }

    final code = prefs.getString(_localeKey);
    if (code == 'en') {
      _locale = const Locale('en', 'US');
    } else if (code == 'tr') {
      _locale = const Locale('tr', 'TR');
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
