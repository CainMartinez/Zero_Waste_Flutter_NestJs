import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/core/l10n/app_localizations.dart';
import 'package:pub_diferent/core/widgets/app_header_logo.dart';
import 'package:pub_diferent/features/auth/presentation/widgets/login_form.dart';
import 'package:pub_diferent/features/auth/presentation/widgets/register_form.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
            children: [
              const SizedBox(height: 6),
              AppHeaderLogo(
                title: _mode == AuthMode.login ? l10n.loginTitle : l10n.registerTitle,
                subtitle: l10n.authSubtitle,
              ),
              const SizedBox(height: 26),

              _AuthModeSwitcher(
                mode: _mode,
                onChanged: (m) {
                  ref.read(authProvider.notifier).clearError();
                  setState(() => _mode = m);
                },
              ),
              const SizedBox(height: 14),

              if (_mode == AuthMode.login)
                _AuthRoleSwitcher(
                  role: _role,
                  onChanged: (r) => setState(() => _role = r),
                ),

              const SizedBox(height: 22),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _mode == AuthMode.login
                    ? LoginForm(
                        key: const ValueKey('login_form'),
                        isAdmin: _role == AuthRole.admin,
                      )
                    : const RegisterForm(
                        key: ValueKey('register_form'),
                      ),
              ),

              const SizedBox(height: 20),
              Text(
                l10n.authAcceptTerms,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthModeSwitcher extends StatelessWidget {
  const _AuthModeSwitcher({
    required this.mode,
    required this.onChanged,
  });

  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Pill(
            label: AppLocalizations.of(context)!.loginButton,
            icon: Icons.login_rounded,
            selected: mode == AuthMode.login,
            onTap: () => onChanged(AuthMode.login),
          ),
          _Pill(
            label: AppLocalizations.of(context)!.registerButton,
            icon: Icons.person_add_alt_1_rounded,
            selected: mode == AuthMode.register,
            onTap: () => onChanged(AuthMode.register),
          ),
        ],
      ),
    );
  }
}

class _AuthRoleSwitcher extends StatelessWidget {
  const _AuthRoleSwitcher({
    required this.role,
    required this.onChanged,
  });

  final AuthRole role;
  final ValueChanged<AuthRole> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _Pill(
            label: AppLocalizations.of(context)!.clientRole,
            icon: Icons.person_outline,
            selected: role == AuthRole.user,
            onTap: () => onChanged(AuthRole.user),
          ),
          _Pill(
            label: AppLocalizations.of(context)!.adminRole,
            icon: Icons.verified_user_outlined,
            selected: role == AuthRole.admin,
            onTap: () => onChanged(AuthRole.admin),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: selected ? cs.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}