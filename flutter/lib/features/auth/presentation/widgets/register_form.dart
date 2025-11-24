import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';
import 'package:eco_bocado/core/utils/error_translator.dart';
import 'package:eco_bocado/core/widgets/app_text_field.dart';
import 'package:eco_bocado/core/widgets/app_password_field.dart';
import 'package:eco_bocado/core/widgets/app_form_submit.dart';
import 'package:eco_bocado/core/utils/validators.dart';
import 'package:eco_bocado/features/auth/presentation/providers/auth_provider.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _errorShown = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _errorShown = false;
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Guardar el contexto antes de hacer la llamada async
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    final notifier = ref.read(authProvider.notifier);
    final user = await notifier.registerUser(
      email: _emailCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    
    if (user != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      final userName = user.name ?? l10n.user;
      final userEmail = user.email ?? '';
      
      // Usar el ScaffoldMessenger guardado que sigue siendo válido
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.registerSuccessMessage(userName, userEmail)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // Detectar errores
    if (authState.hasError && !_errorShown) {
      _errorShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context)!;
        final errorString = authState.error?.toString() ?? l10n.errorRegisterFailed;
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
            controller: _nameCtrl,
            label: AppLocalizations.of(context)!.name,
            textInputAction: TextInputAction.next,
            validator: (v) => Validators.name(context, v),
          ),
          const SizedBox(height: 12),
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
            label: isLoading ? AppLocalizations.of(context)!.creatingAccount : AppLocalizations.of(context)!.createAccount,
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}