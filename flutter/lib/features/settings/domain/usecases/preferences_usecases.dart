import 'package:eco_bocado/features/settings/domain/entities/preferences.dart';
import 'package:eco_bocado/features/settings/domain/repositories/preferences_repository.dart';

class PreferencesUseCases {
  final Future<Preferences> Function() getPreferences;
  final Future<void> Function(Preferences preference, String key) setPreferences;

  PreferencesUseCases(PreferencesRepository repo)
      : getPreferences = repo.getPreferences,
        setPreferences = repo.setPreferences;
}
