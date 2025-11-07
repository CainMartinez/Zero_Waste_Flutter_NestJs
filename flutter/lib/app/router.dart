import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pub_diferent/core/layout/app_shell.dart';
import 'package:pub_diferent/features/home/presentation/pages/home_page.dart';

import 'package:pub_diferent/features/auth/presentation/pages/auth_page.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _menuNavKey = GlobalKey<NavigatorState>(debugLabel: 'menuNav');
final _ordersNavKey = GlobalKey<NavigatorState>(debugLabel: 'ordersNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(
          navigationShell: navigationShell,
        ),
        branches: [
          // HOME
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePage(),
                ),
              ),
            ],
          ),

          // MENÚ
          StatefulShellBranch(
            navigatorKey: _menuNavKey,
            routes: [
              GoRoute(
                path: '/menu',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Center(child: Text('Página de menú')),
                ),
              ),
            ],
          ),

          // PEDIDOS (guard en pageBuilder)
          StatefulShellBranch(
            navigatorKey: _ordersNavKey,
            routes: [
              GoRoute(
                path: '/orders',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _AuthGate(
                    logged: Center(child: Text('Listado de pedidos')),
                    anonymous: AuthPage(),
                  ),
                ),
              ),
            ],
          ),

          // PERFIL (guard en pageBuilder)
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: _AuthGate(
                    logged: Center(child: Text('Página de perfil')),
                    anonymous: AuthPage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Pequeño gate que decide qué mostrar en función del estado de auth
class _AuthGate extends ConsumerWidget {
  const _AuthGate({
    required this.logged,
    required this.anonymous,
  });

  final Widget logged;
  final Widget anonymous;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // Cargando/recuperando sesión (evita parpadeos y rutas equivocadas)
    if (auth.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si tenemos valor, decidimos por sesión
    final value = auth.hasValue ? auth.value : null;
    final isLogged = _isLogged(value);

    return isLogged ? logged : anonymous;
  }
}

bool _isLogged(AuthViewState? s) {
  if (s == null) return false;
  return s.userSession != null || s.adminSession != null;
}