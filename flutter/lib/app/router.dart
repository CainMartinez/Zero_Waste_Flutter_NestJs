import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:pub_diferent/core/layout/app_shell.dart';
import 'package:pub_diferent/features/home/presentation/pages/home_page.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'homeNav');
final _menuNavKey = GlobalKey<NavigatorState>(debugLabel: 'menuNav');
final _ordersNavKey = GlobalKey<NavigatorState>(debugLabel: 'ordersNav');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profileNav');

GoRouter createRouter({
  required SettingsController settingsController,
}) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell, settingsController: settingsController),
        branches: [
          // HOME
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: HomePage(settingsController: settingsController),
                ),
              ),
            ],
          ),

          // MENÚ (ahora usando CatalogPage como placeholder)
          StatefulShellBranch(
            navigatorKey: _menuNavKey,
            routes: [
              GoRoute(
                path: '/menu',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: Center(child: Text('Página de menú')),
                ),
              ),
            ],
          ),

          // PEDIDOS (stub temporal)
          StatefulShellBranch(
            navigatorKey: _ordersNavKey,
            routes: [
              GoRoute(
                path: '/orders',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Center(child: Text('Página de pedidos')),
                ),
              ),
            ],
          ),

          // PERFIL (stub temporal)
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Center(child: Text('Página de perfil')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}