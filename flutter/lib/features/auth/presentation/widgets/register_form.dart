import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/core/widgets/app_text_field.dart';
import 'package:pub_diferent/core/widgets/app_password_field.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';
import 'package:pub_diferent/features/auth/data/dto/request/register_user_request_dto.dart';
import 'package:pub_diferent/features/auth/presentation/providers/auth_provider.dart'; 

/// Formulario de alta de usuario (POST /auth/register).
/// - Valida con el DTO
/// - Llama al AuthRepository (no gestiona sesión ni tokens).
/// - En éxito, muestra "Te has registrado con éxito, -nombre-".
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

  Map<String, String>? _fieldErrors;

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _fieldErrors = null);

    final dto = RegisterUserRequestDto.create(
      email: _emailCtrl.text,
      name: _nameCtrl.text,
      password: _passwordCtrl.text,
    );
    final errors = dto.validate();
    if (errors != null) {
      setState(() => _fieldErrors = errors);
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    setState(() => _isLoading = true);
    try {
      final user = await repo.registerUser(
        email: dto.email,
        name: dto.name,
        password: dto.password,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te has registrado con éxito, ${user.name}.')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            controller: _nameCtrl,
            label: 'Nombre',
            hint: 'Tu nombre',
            textInputAction: TextInputAction.next,
            errorText: _fieldErrors?['name'],
          ),
          const SizedBox(height: 12),

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
              if (!_isLoading) _submit();
            },
            errorText: _fieldErrors?['password'],
          ),
          const SizedBox(height: 20),

          AppFormSubmit(
            label: _isLoading ? 'Creando cuenta...' : 'Crear cuenta',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }
}