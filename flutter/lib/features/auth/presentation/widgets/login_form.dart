import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:eco_bocado/core/l10n/app_localizations.dart';
import 'package:eco_bocado/core/utils/error_translator.dart';
import 'package:eco_bocado/core/widgets/app_text_field.dart';
import 'package:eco_bocado/core/widgets/app_password_field.dart';
import 'package:eco_bocado/core/widgets/app_form_submit.dart';
import 'package:eco_bocado/core/utils/validators.dart';
import 'package:eco_bocado/features/auth/presentation/providers/auth_provider.dart';

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
        final l10n = AppLocalizations.of(context)!;
        final errorString = authState.error?.toString() ?? l10n.errorLoginFailed;
        // Traducir error usando ErrorTranslator
        final message = ErrorTranslator.translate(context, errorString);
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
            validator: (v) => Validators.email(context, v),
          ),
          const SizedBox(height: 12),
          AppPasswordField(
            controller: _passwordCtrl,
            label: AppLocalizations.of(context)!.password,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!isLoading) _submit();
            },
            validator: (v) => Validators.password(context, v),
          ),
          const SizedBox(height: 20),
          AppFormSubmit(
            label: isLoading ? AppLocalizations.of(context)!.loggingIn : AppLocalizations.of(context)!.login,
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
