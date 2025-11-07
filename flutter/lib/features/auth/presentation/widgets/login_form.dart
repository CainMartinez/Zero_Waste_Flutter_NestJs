import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pub_diferent/core/widgets/app_text_field.dart';
import 'package:pub_diferent/core/widgets/app_password_field.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';
import 'package:pub_diferent/core/utils/validators.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({
    super.key,
    this.isAdmin = false,
  });

  final bool isAdmin;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _errorShown = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorShown = false;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final notifier = ref.read(authProvider.notifier);

    if (widget.isAdmin) {
      await notifier.loginAdmin(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    } else {
      await notifier.loginUser(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // Detectar errores directamente en el build
    if (authState.hasError && !_errorShown) {
      _errorShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final errorString = authState.error?.toString() ?? 'No se pudo iniciar sesión';
        // Quitar el prefijo "Exception: " si existe
        final message = errorString.startsWith('Exception: ') 
            ? errorString.substring(11) 
            : errorString;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          const SizedBox(height: 12),
          AppPasswordField(
            controller: _passwordCtrl,
            label: 'Contraseña',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) _submit();
            },
            validator: Validators.password,
          ),
          const SizedBox(height: 20),
          AppFormSubmit(
            label: isLoading ? 'Entrando...' : 'Entrar',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
