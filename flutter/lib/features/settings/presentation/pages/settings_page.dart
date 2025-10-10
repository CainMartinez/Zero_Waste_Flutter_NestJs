import 'package:flutter/material.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';
import 'package:pub_diferent/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:pub_diferent/features/settings/presentation/widgets/settings_switch_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final SettingsController controller;

  String _languageLabel(String code) {
    return switch (code) {
      'en' => 'Inglés',
      'es' => 'Español',
      _ => code.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Preferencias')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SettingsSectionTitle(text: 'Notificaciones'),
              SettingsSwitchTile(
                label: 'Notificaciones de la app',
                value: controller.appNotifications,
                onChanged: controller.setAppNotifications,
              ),
              SettingsSwitchTile(
                label: 'Notificaciones por email',
                value: controller.emailNotifications,
                onChanged: controller.setEmailNotifications,
              ),
              SettingsSwitchTile(
                label: 'Notificaciones por WhatsApp',
                value: controller.whatsappNotifications,
                onChanged: controller.setWhatsappNotifications,
              ),
              const SizedBox(height: 24),
              const SettingsSectionTitle(text: 'Personalización'),
              SettingsSwitchTile(
                label: 'Modo oscuro',
                value: controller.darkMode,
                onChanged: controller.setDarkMode,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Idioma'),
                subtitle: Text(_languageLabel(controller.language)),
                trailing: DropdownButton<String>(
                  value: controller.language,
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'en', child: Text('Inglés')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLanguage(value);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
