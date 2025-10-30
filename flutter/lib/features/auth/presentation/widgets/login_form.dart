import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pub_diferent/core/widgets/app_text_field.dart';
import 'package:pub_diferent/core/widgets/app_password_field.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';

import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';
import 'package:pub_diferent/features/auth/data/dto/request/login_request_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/request/admin_login_request_dto.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key, this.isAdmin = false});

  final bool isAdmin;

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  Map<String, String>? _fieldErrors;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _fieldErrors = null);

    if (widget.isAdmin) {
      final dto = AdminLoginRequestDto.create(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      final errors = dto.validate();
      if (errors != null) {
        setState(() => _fieldErrors = errors);
        return;
      }

      await ref
          .read(authProvider.notifier)
          .loginAdmin(_emailCtrl.text.trim(), _passwordCtrl.text);
    } else {
      final dto = LoginRequestDto.create(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      final errors = dto.validate();
      if (errors != null) {
        setState(() => _fieldErrors = errors);
        return;
      }

      await ref
          .read(authProvider.notifier)
          .loginUser(_emailCtrl.text.trim(), _passwordCtrl.text);
    }

    final auth = ref.read(authProvider);

    if (!auth.isAuthenticated && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo iniciar sesión. Revisa tus credenciales.'),
        ),
      );
      return;
    }

    final name = auth.userSession?.user.name ?? auth.adminSession?.admin.name;
    if (name != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenido, $name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isLoading = auth.isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'tu@email.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            errorText: _fieldErrors?['email'],
          ),
          const SizedBox(height: 12),
          AppPasswordField(
            controller: _passwordCtrl,
            label: 'Contraseña',
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) _submit();
            },
            errorText: _fieldErrors?['password'],
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