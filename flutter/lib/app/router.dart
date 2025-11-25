import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:eco_bocado/core/layout/app_shell.dart';
import 'package:eco_bocado/features/home/presentation/pages/home_page.dart';
import 'package:eco_bocado/features/profile/presentation/pages/profile_page.dart';
import 'package:eco_bocado/features/shop/presentation/pages/shop_page.dart';
import 'package:eco_bocado/features/admin/presentation/pages/products_admin_page.dart';

import 'package:eco_bocado/core/widgets/auth_gate.dart';

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
                authPageKey: ValueKey('orders-auth'),
                child: Center(child: Text('Listado de pedidos')),
              ),
            ),
          ),
          
          // Rutas para ADMIN
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                authPageKey: ValueKey('dashboard-auth'),
                child: Center(child: Text('Dashboard - Datos globales de la aplicación')),
              ),
            ),
          ),
          GoRoute(
            path: '/products',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                authPageKey: ValueKey('products-auth'),
                child: ProductsAdminPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/billing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                authPageKey: ValueKey('billing-auth'),
                child: Center(child: Text('Facturación')),
              ),
            ),
          ),
          
          // Ruta de perfil (común)
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuthGate(
                authPageKey: ValueKey('profile-auth'),
                child: ProfilePage(),
              ),
            ),
          ),
        ],
      ),
    ],
  );
});