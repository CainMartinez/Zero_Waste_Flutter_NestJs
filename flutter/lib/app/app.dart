import 'package:flutter/material.dart';
import 'package:pub_diferent/app/router.dart';
import 'package:pub_diferent/app/theme/app_theme.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';

/// Widget raíz de la aplicación.
/// Configura el tema y el router principal (con navegación inferior persistente).
class PubDiferentApp extends StatelessWidget {
  const PubDiferentApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Inicializa el router principal pasando el controlador de ajustes.
    final router = createRouter(settingsController: settingsController);

    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Pub Diferent',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: settingsController.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}