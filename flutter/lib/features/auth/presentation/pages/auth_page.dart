import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/features/auth/presentation/widgets/login_form.dart';
import 'package:pub_diferent/features/auth/presentation/widgets/register_form.dart';

enum AuthMode { login, register }
enum AuthRole { user, admin }

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  AuthMode _mode = AuthMode.login;
  AuthRole _role = AuthRole.user;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                _mode == AuthMode.login ? 'Inicia sesión' : 'Crear cuenta',
                style: tt.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _mode == AuthMode.login
                    ? 'Selecciona el tipo de acceso y tus credenciales.'
                    : 'Completa tus datos para registrarte.',
                style: tt.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Toggle principal Login / Registro
              _ModeSegmented(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
              const SizedBox(height: 16),

              // Toggle User / Admin SOLO en modo login
              if (_mode == AuthMode.login)
                _RoleSegmented(
                  role: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _mode == AuthMode.login
                    ? LoginForm(
                        key: const ValueKey('login_form'),
                        isAdmin: _role == AuthRole.admin,
                      )
                    : const RegisterForm(
                        key: ValueKey('register_form'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSegmented extends StatelessWidget {
  const _ModeSegmented({
    required this.mode,
    required this.onChanged,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = mode == AuthMode.login ? 0 : 1;
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Login'), icon: Icon(Icons.login)),
        ButtonSegment(value: 1, label: Text('Registro'), icon: Icon(Icons.person_add_alt_1)),
      ],
      selected: {selected},
      onSelectionChanged: (s) {
        if (s.contains(0)) onChanged(AuthMode.login);
        if (s.contains(1)) onChanged(AuthMode.register);
      },
    );
  }
}

class _RoleSegmented extends StatelessWidget {
  const _RoleSegmented({
    required this.role,
    required this.onChanged,
  });

  final AuthRole role;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = role == AuthRole.user ? 0 : 1;
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment(value: 0, label: Text('Cliente'), icon: Icon(Icons.person)),
        ButtonSegment(value: 1, label: Text('Admin'), icon: Icon(Icons.security)),
      ],
      selected: {selected},
      onSelectionChanged: (s) {
        if (s.contains(0)) onChanged(AuthRole.user);
        if (s.contains(1)) onChanged(AuthRole.admin);
      },
    );
  }
}