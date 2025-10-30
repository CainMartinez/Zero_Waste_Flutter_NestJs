import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';
import 'package:pub_diferent/features/settings/presentation/pages/settings_page.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

class AppShell extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final currentIndex = navigationShell.currentIndex;
    final titles = ['Inicio', 'Menú', 'Pedidos', 'Perfil'];
    final currentTitle = titles[currentIndex];

    final auth = ref.watch(authProvider);
    final isLogged = auth.isAuthenticated;
    final displayName =
        auth.userSession?.user.name ?? auth.adminSession?.admin.name;
    final avatarUrl =
        auth.userSession?.user.avatarUrl ?? auth.adminSession?.admin.avatarUrl;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => navigationShell.goBranch(0),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.jpg', height: 72),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pub Diferent',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        currentTitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 1,
              height: 24,
              color: cs.outlineVariant.withOpacity(0.4),
            ),
            const SizedBox(width: 16),
          ],
        ),
        actions: [
          if (isLogged && displayName != null) ...[
            GestureDetector(
              onTap: () => navigationShell.goBranch(3),
              child: Text(
                'Hola, $displayName',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => navigationShell.goBranch(3),
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: cs.secondaryContainer,
                backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, size: 18)
                    : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Preferencias',
            onPressed: () => _openSettings(context),
          ),
          const SizedBox(width: 6),
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