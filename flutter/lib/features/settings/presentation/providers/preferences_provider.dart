import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pub_diferent/features/settings/data/datasources/preferences_local_datasource.dart';
import 'package:pub_diferent/features/settings/data/repositories/preferences_repository_impl.dart';
import 'package:pub_diferent/features/settings/domain/entities/preferences.dart';
import 'package:pub_diferent/features/settings/domain/repositories/preferences_repository.dart';
import 'package:pub_diferent/features/settings/domain/usecases/preferences_usecases.dart';

/// Provider para SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

/// DataSource
final preferencesLocalDSProvider = Provider<PreferencesLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PreferencesLocalDataSource(prefs);
});

/// Repositorio
final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final ds = ref.watch(preferencesLocalDSProvider);
  return PreferencesRepositoryImpl(localDataSource: ds);
});

/// Casos de uso
final preferencesUseCasesProvider = Provider<PreferencesUseCases>((ref) {
  final repo = ref.watch(preferencesRepositoryProvider);
  return PreferencesUseCases(repo);
});

/// Notifier para manejar el estado de las preferencias
class PreferencesNotifier extends AsyncNotifier<Preferences> {
  late final PreferencesUseCases preferencesUseCases;

  /// Inicializa el Notifier
  @override
  Future<Preferences> build() async {
    preferencesUseCases = ref.watch(preferencesUseCasesProvider);

    // Carga inicial de preferencias desde SharedPreferences
    return await preferencesUseCases.getPreferences();
  }

  /// Actualiza la preferencia de notificaciones de la app
  Future<void> updateAppNotifications(bool value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(appNotifications: value),
      Preferences.appNotificationsConst,
    );
  }

  /// Actualiza la preferencia de notificaciones por email
  Future<void> updateEmailNotifications(bool value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(emailNotifications: value),
      Preferences.emailNotificationsConst,
    );
  }

  /// Actualiza la preferencia de notificaciones por WhatsApp
  Future<void> updateWhatsappNotifications(bool value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(whatsappNotifications: value),
      Preferences.whatsappNotificationsConst,
    );
  }

  /// Actualiza la preferencia de modo oscuro
  Future<void> updateDarkMode(bool value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(darkMode: value),
      Preferences.darkModeConst,
    );
  }

  /// Actualiza la preferencia de idioma
  Future<void> updateLanguage(String value) async {
    await _updatePreference(
      (prefs) => prefs.copyWith(language: value),
      Preferences.languageConst,
    );
  }

  /// Método privado genérico para actualizar preferencias
  Future<void> _updatePreference(
    Preferences Function(Preferences) update,
    String key,
  ) async {
    final prev = state.value; // Guarda el estado previo para rollback
    if (prev == null) return; // No hace nada si no hay estado previo

    final newPreference = update(prev); // Crea la nueva preferencia con el cambio
    state = AsyncValue.data(newPreference); // Actualiza el estado inmediatamente (optimistic update)

    try {
      await preferencesUseCases.setPreferences(newPreference, key); // Guarda en SharedPreferences
      // Recarga desde SharedPreferences para confirmar
      state = await AsyncValue.guard(() => preferencesUseCases.getPreferences());
    } catch (error, stack) {
      // Rollback si hay error
      state = AsyncValue.data(prev);
      state = AsyncError(error, stack);
    }
  }
}

/// Provider principal para las preferencias
final preferencesProvider = AsyncNotifierProvider<PreferencesNotifier, Preferences>(() {
  return PreferencesNotifier();
});
