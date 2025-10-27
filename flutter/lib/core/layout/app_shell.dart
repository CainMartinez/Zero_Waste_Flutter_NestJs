import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';
import 'package:pub_diferent/features/settings/presentation/pages/settings_page.dart';

/// Estructura base de la aplicación:
/// - AppBar con título dinámico y botón de preferencias.
/// - NavigationBar persistente con 4 secciones (Inicio, Menú, Pedidos, Perfil).
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
    this.settingsController,
  });

  final StatefulNavigationShell navigationShell;
  final SettingsController? settingsController;

  void _openSettings(BuildContext context) {
    if (settingsController == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsPage(controller: settingsController!),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Determina el título del AppBar según la pestaña activa
    final currentIndex = navigationShell.currentIndex;
    final titles = ['Inicio', 'Menú', 'Pedidos', 'Perfil'];
    final currentTitle = titles[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Preferencias',
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menú',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        backgroundColor: cs.surface,
      ),
    );
  }
}