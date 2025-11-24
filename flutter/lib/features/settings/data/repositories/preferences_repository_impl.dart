import 'package:eco_bocado/features/settings/data/datasources/preferences_local_datasource.dart';
import 'package:eco_bocado/features/settings/domain/entities/preferences.dart';
import 'package:eco_bocado/features/settings/domain/repositories/preferences_repository.dart';

class PreferencesRepositoryImpl implements PreferencesRepository {
  final PreferencesLocalDataSource localDataSource;
  
  PreferencesRepositoryImpl({required this.localDataSource});

  @override
  Future<Preferences> getPreferences() async {
    return await localDataSource.getPreferences();
  }

  @override
  Future<void> setPreferences(Preferences preference, String key) async {
    await localDataSource.savePreferences(preference, key);
  }
}
