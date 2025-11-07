import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/catalog/catalog_page.dart';
import 'package:pub_diferent/core/widgets/primary_cta_bar.dart';
import 'package:pub_diferent/features/settings/presentation/providers/preferences_provider.dart';
import 'package:pub_diferent/features/settings/presentation/widgets/settings_section_title.dart';
import 'package:pub_diferent/features/settings/presentation/widgets/settings_switch_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  String _languageLabel(String code) {
    return switch (code) {
      'en' => 'Inglés',
      'es' => 'Español',
      _ => code.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: preferencesAsync.when(
        data: (preferences) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SettingsSectionTitle(text: 'Notificaciones'),
            SettingsSwitchTile(
              label: 'Notificaciones en la App',
              value: preferences.appNotifications ?? false,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).updateAppNotifications(value);
              },
            ),
            SettingsSwitchTile(
              label: 'Notificaciones por Email',
              value: preferences.emailNotifications ?? false,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).updateEmailNotifications(value);
              },
            ),
            SettingsSwitchTile(
              label: 'Notificaciones por WhatsApp',
              value: preferences.whatsappNotifications ?? false,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).updateWhatsappNotifications(value);
              },
            ),
            const SizedBox(height: 24),
            const SettingsSectionTitle(text: 'Apariencia'),
            SettingsSwitchTile(
              label: 'Modo Oscuro',
              value: preferences.darkMode ?? false,
              onChanged: (value) {
                ref.read(preferencesProvider.notifier).updateDarkMode(value);
              },
            ),
            const SizedBox(height: 24),
            const SettingsSectionTitle(text: 'Idioma'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Idioma'),
              subtitle: Text(_languageLabel(preferences.language ?? 'es')),
              trailing: DropdownButton<String>(
                value: preferences.language ?? 'es',
                items: const [
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                  DropdownMenuItem(value: 'en', child: Text('Inglés')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(preferencesProvider.notifier).updateLanguage(value);
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error al cargar preferencias: $error'),
        ),
      ),
      bottomNavigationBar: PrimaryCtaBar(
        label: 'Ver Catálogo',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CatalogPage()),
          );
        },
      ),
    );
  }
}