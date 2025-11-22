import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pub_diferent/core/layout/app_shell.dart';
import 'package:pub_diferent/features/home/presentation/pages/home_page.dart';
import 'package:pub_diferent/features/profile/presentation/pages/profile_page.dart';
import 'package:pub_diferent/features/shop/presentation/pages/shop_page.dart';
import 'package:pub_diferent/features/admin/presentation/pages/products_admin_page.dart';

import 'package:pub_diferent/core/widgets/auth_gate.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Provider del router para evitar recrearlo en cada build
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(
          child: child,
        ),
        routes: [
          // Ruta de inicio para USUARIOS
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          
          // Rutas para USUARIOS
          GoRoute(
            path: '/menu',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ShopPage(),
            ),
          ),
          GoRoute(
            path: '/orders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: Center(child: Text('Listado de pedidos')),
                authPageKey: ValueKey('orders-auth'),
              ),
            ),
          ),
          
          // Rutas para ADMIN
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: Center(child: Text('Dashboard - Datos globales de la aplicación')),
                authPageKey: ValueKey('dashboard-auth'),
              ),
            ),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: ProductsAdminPage(),
                authPageKey: ValueKey('products-auth'),
              ),
            ),
          ),
          GoRoute(
            path: '/billing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: Center(child: Text('Facturación')),
                authPageKey: ValueKey('billing-auth'),
              ),
            ),
          ),
          
          // Ruta de perfil (común)
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                child: ProfilePage(),
                authPageKey: ValueKey('profile-auth'),
              ),
            ),
          ),
        ],
      ),
    ],
  );
});