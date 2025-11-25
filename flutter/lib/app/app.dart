import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bocado/app/router.dart';
import 'package:eco_bocado/app/theme/app_theme.dart';
import 'package:eco_bocado/features/settings/presentation/providers/preferences_provider.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';

/// Widget raíz de la aplicación.
/// Configura el tema y el router principal (con navegación inferior persistente).
class EcoBocadoApp extends ConsumerWidget {
  const EcoBocadoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usa el router desde el provider (no se recrea en cada build)
    final router = ref.watch(routerProvider);
    
    // Observa las preferencias para obtener el modo oscuro y el idioma
    final preferencesAsync = ref.watch(preferencesProvider);
    final darkMode = preferencesAsync.when(
      data: (prefs) => prefs.darkMode ?? false,
      loading: () => false,
      error: (_, _) => false,
    );
    
    final languageCode = preferencesAsync.when(
      data: (prefs) => prefs.language ?? 'es',
      loading: () => 'es',
      error: (_, _) => 'es',
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'EcoBocado',
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