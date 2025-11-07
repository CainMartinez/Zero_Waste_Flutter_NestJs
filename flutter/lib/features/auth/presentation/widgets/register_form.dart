import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/core/widgets/app_text_field.dart';
import 'package:pub_diferent/core/widgets/app_password_field.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';
import 'package:pub_diferent/core/utils/validators.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart';

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
    
    if (user != null) {
      final userName = user.name ?? 'Usuario';
      final userEmail = user.email ?? '';
      
      // Usar el ScaffoldMessenger guardado que sigue siendo válido
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('¡Te has registrado con éxito $userName con el email $userEmail!'),
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
        final errorString = authState.error?.toString() ?? 'Error en el registro';
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
            controller: _nameCtrl,
            label: 'Nombre',
            textInputAction: TextInputAction.next,
            validator: Validators.name,
          ),
          const SizedBox(height: 12),
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
            label: isLoading ? 'Creando cuenta...' : 'Crear cuenta',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}