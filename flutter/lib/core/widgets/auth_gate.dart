import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bocado/features/auth/presentation/pages/auth_page.dart';
import 'package:eco_bocado/features/auth/presentation/providers/auth_provider.dart';

/// Widget que decide qué mostrar en función del estado de autenticación
class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.child,
    this.authPageKey,
  });

  final Widget child;
  final Key? authPageKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return auth.when(
      data: (authState) {
        final isLogged = authState.userSession != null || 
                        authState.adminSession != null;
        return isLogged ? child : AuthPage(key: authPageKey);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => AuthPage(key: authPageKey),
    );
  }
}