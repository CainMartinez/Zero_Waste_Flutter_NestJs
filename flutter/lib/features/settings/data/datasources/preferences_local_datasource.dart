import 'package:eco_bocado/features/settings/domain/entities/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesLocalDataSource {
  final SharedPreferences _prefs;

  PreferencesLocalDataSource(this._prefs);

  static const String _appNotificationsKey = 'pref_app_notifications';
  static const String _emailNotificationsKey = 'pref_email_notifications';
  static const String _whatsappNotificationsKey = 'pref_whatsapp_notifications';
  static const String _darkModeKey = 'pref_dark_mode';
  static const String _languageKey = 'pref_language';

  static const bool _defaultAppNotifications = false;
  static const bool _defaultEmailNotifications = false;
  static const bool _defaultWhatsappNotifications = false;
  static const bool _defaultDarkMode = false;
  static const String _defaultLanguage = 'es';

  Future<SharedPreferences> fetchPreferences() async {
    return _prefs;
  }

  Future<Preferences> getPreferences() async {
    return Preferences(
      appNotifications: _prefs.getBool(_appNotificationsKey) ?? _defaultAppNotifications,
      emailNotifications: _prefs.getBool(_emailNotificationsKey) ?? _defaultEmailNotifications,
      whatsappNotifications: _prefs.getBool(_whatsappNotificationsKey) ?? _defaultWhatsappNotifications,
      darkMode: _prefs.getBool(_darkModeKey) ?? _defaultDarkMode,
      language: _prefs.getString(_languageKey) ?? _defaultLanguage,
    );
  }

  Future<void> savePreferences(Preferences preference, String key) async {
    if (key == Preferences.appNotificationsConst && preference.appNotifications != null) {
      await _prefs.setBool(_appNotificationsKey, preference.appNotifications!);
    }
    if (key == Preferences.emailNotificationsConst && preference.emailNotifications != null) {
      await _prefs.setBool(_emailNotificationsKey, preference.emailNotifications!);
    }
    if (key == Preferences.whatsappNotificationsConst && preference.whatsappNotifications != null) {
      await _prefs.setBool(_whatsappNotificationsKey, preference.whatsappNotifications!);
    }
    if (key == Preferences.darkModeConst && preference.darkMode != null) {
      await _prefs.setBool(_darkModeKey, preference.darkMode!);
    }
    if (key == Preferences.languageConst && preference.language != null) {
      await _prefs.setString(_languageKey, preference.language!);
    }
  }
}
