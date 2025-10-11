import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._(this._prefs)
    : _appNotifications =
          _prefs.getBool(_appNotificationsKey) ?? _defaultAppNotifications,
      _emailNotifications =
          _prefs.getBool(_emailNotificationsKey) ?? _defaultEmailNotifications,
      _whatsappNotifications =
          _prefs.getBool(_whatsappNotificationsKey) ??
          _defaultWhatsappNotifications,
      _darkMode = _prefs.getBool(_darkModeKey) ?? _defaultDarkMode,
      _language = _prefs.getString(_languageKey) ?? _defaultLanguage;

  static const _appNotificationsKey = 'pref_app_notifications';
  static const _emailNotificationsKey = 'pref_email_notifications';
  static const _whatsappNotificationsKey = 'pref_whatsapp_notifications';
  static const _darkModeKey = 'pref_dark_mode';
  static const _languageKey = 'pref_language';

  static const bool _defaultAppNotifications = false;
  static const bool _defaultEmailNotifications = false;
  static const bool _defaultWhatsappNotifications = false;
  static const bool _defaultDarkMode = false;
  static const String _defaultLanguage = 'es';

  final SharedPreferences _prefs;

  bool _appNotifications;
  bool _emailNotifications;
  bool _whatsappNotifications;
  bool _darkMode;
  String _language;

  static Future<SettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsController._(prefs);
  }

  bool get appNotifications => _appNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get whatsappNotifications => _whatsappNotifications;
  bool get darkMode => _darkMode;
  String get language => _language;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setAppNotifications(bool value) async {
    if (_appNotifications == value) return;
    _appNotifications = value;
    await _prefs.setBool(_appNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setEmailNotifications(bool value) async {
    if (_emailNotifications == value) return;
    _emailNotifications = value;
    await _prefs.setBool(_emailNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setWhatsappNotifications(bool value) async {
    if (_whatsappNotifications == value) return;
    _whatsappNotifications = value;
    await _prefs.setBool(_whatsappNotificationsKey, value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_darkMode == value) return;
    _darkMode = value;
    await _prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    if (_language == value) return;
    _language = value;
    await _prefs.setString(_languageKey, value);
    notifyListeners();
  }
}
