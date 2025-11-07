import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pub_diferent/core/layout/app_shell.dart';
import 'package:pub_diferent/features/home/presentation/pages/home_page.dart';
import 'package:pub_diferent/features/profile/presentation/pages/profile_page.dart';

import 'package:pub_diferent/features/auth/presentation/pages/auth_page.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: Center(child: Text('Página de menú')),
            ),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => NoTransitionPage(
              child: _AuthGate(
                logged: const Center(child: Text('Listado de pedidos')),
                anonymous: const AuthPage(key: ValueKey('orders-auth')),
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: _AuthGate(
                logged: const ProfilePage(),
                anonymous: const AuthPage(key: ValueKey('profile-auth')),
              ),
            ),
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

    return auth.when(
      data: (authState) {
        final isLogged = authState.userSession != null || authState.adminSession != null;
        return isLogged ? logged : anonymous;
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => anonymous,
    );
  }
}