import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_diferent/features/settings/presentation/pages/settings_page.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final authAsync = ref.watch(authProvider);
        
    final auth = authAsync.when(
      data: (value) => value,
      loading: () => null,
      error: (e, st) => null,
    );

    final isLogged = auth?.isAuthenticated ?? false;
    final isAdmin = auth?.isAdmin ?? false;
    final displayName = auth?.displayName;
    final avatarUrl = auth?.avatarUrl;

    // Definir rutas y títulos según el rol
    final List<String> paths;
    final List<String> titles;
    
    if (isAdmin) {
      // Rutas para ADMIN: Dashboard, Productos, Facturación, Perfil
      paths = ['/dashboard', '/products', '/billing', '/profile'];
      titles = ['Dashboard', 'Productos', 'Facturación', 'Perfil'];
    } else {
      // Rutas para USUARIO: Inicio, Menú, Pedidos, Perfil
      paths = ['/home', '/menu', '/orders', '/profile'];
      titles = ['Inicio', 'Menú', 'Pedidos', 'Perfil'];
    }

    // Obtener el índice actual basado en la ruta
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = paths.indexOf(location);
    final selectedIndex = currentIndex >= 0 ? currentIndex : 0;

    final currentTitle = titles[selectedIndex];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => context.go(isAdmin ? '/dashboard' : '/home'),
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
              onTap: () => context.go('/profile'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hola, $displayName',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (auth?.isAdmin == true) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          GestureDetector(
            onTap: () => context.go('/profile'),
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
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => context.go(paths[index]),
        destinations: isAdmin
            ? const [
                // Navegación para ADMIN
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined),
                  selectedIcon: Icon(Icons.inventory_2),
                  label: 'Productos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_outlined),
                  selectedIcon: Icon(Icons.receipt),
                  label: 'Facturación',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ]
            : const [
                // Navegación para USUARIO
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