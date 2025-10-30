import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pub_diferent/core/layout/app_shell.dart';
import 'package:pub_diferent/features/home/presentation/pages/home_page.dart';
import 'package:pub_diferent/features/settings/presentation/controllers/settings_controller.dart';
import 'package:pub_diferent/features/auth/presentation/pages/auth_page.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

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

          StatefulShellBranch(
            navigatorKey: _ordersNavKey,
            routes: [
              GoRoute(
                path: '/orders',
                redirect: (context, state) {
                  final container = ProviderScope.containerOf(context, listen: false);
                  final auth = container.read(authProvider);
                  final loggedIn =
                      auth.userSession != null || auth.adminSession != null;

                  return loggedIn ? '/orders/list' : '/orders/auth';
                },
              ),
              GoRoute(
                path: '/orders/list',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Center(child: Text('Listado de pedidos')),
                ),
              ),
              GoRoute(
                path: '/orders/auth',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AuthPage(),
                ),
              ),
            ],
          ),

          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: '/profile',
                redirect: (context, state) {
                  final container = ProviderScope.containerOf(context, listen: false);
                  final auth = container.read(authProvider);
                  final loggedIn =
                      auth.userSession != null || auth.adminSession != null;
                  return loggedIn ? '/profile/me' : '/profile/auth';
                },
              ),
              GoRoute(
                path: '/profile/me',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: Center(child: Text('Página de perfil')),
                ),
              ),
              GoRoute(
                path: '/profile/auth',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AuthPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}