import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/app/router.dart';
import 'package:pub_diferent/app/theme/app_theme.dart';
import 'package:pub_diferent/features/settings/presentation/providers/preferences_provider.dart';
import 'package:pub_diferent/core/l10n/app_localizations.dart';

/// Widget raíz de la aplicación.
/// Configura el tema y el router principal (con navegación inferior persistente).
class PubDiferentApp extends ConsumerWidget {
  const PubDiferentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa el router desde el provider (no se recrea en cada build)
    final router = ref.watch(routerProvider);
    
    // Observa las preferencias para obtener el modo oscuro y el idioma
    final preferencesAsync = ref.watch(preferencesProvider);
    final darkMode = preferencesAsync.when(
      data: (prefs) => prefs.darkMode ?? false,
      loading: () => false,
      error: (_, __) => false,
    );
    
    final languageCode = preferencesAsync.when(
      data: (prefs) => prefs.language ?? 'es',
      loading: () => 'es',
      error: (_, __) => 'es',
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Pub Diferent',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Configuración de localización
      locale: Locale(languageCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      
      routerConfig: router,
    );
  }
}