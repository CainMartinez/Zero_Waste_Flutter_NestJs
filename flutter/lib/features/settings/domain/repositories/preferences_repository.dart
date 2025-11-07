import 'package:pub_diferent/features/settings/domain/entities/preferences.dart';

abstract class PreferencesRepository {
  Future<Preferences> getPreferences();
  Future<void> setPreferences(Preferences preference, String key);
}
