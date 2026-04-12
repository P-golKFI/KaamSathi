import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';

  Locale _locale = const Locale('en');

  /// The currently active locale.
  Locale get locale => _locale;

  /// Called at startup — reads the saved language code from device storage.
  /// Returns English if nothing has been saved yet (first launch).
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    return code != null ? Locale(code) : const Locale('en');
  }

  /// Returns true if the user has already chosen a language before.
  static Future<bool> hasChosenLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  /// Sets the active locale, notifies all screens to rebuild,
  /// and saves the choice to device storage.
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners(); // tells every screen using this provider to redraw
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  /// Initialises the provider with a locale read before runApp().
  void init(Locale locale) {
    _locale = locale;
  }
}
