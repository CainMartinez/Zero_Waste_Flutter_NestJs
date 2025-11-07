import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pub_diferent/features/profile/presentation/providers/profile_provider.dart';
import 'package:pub_diferent/core/widgets/app_password_field.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';
import 'package:pub_diferent/core/utils/validators.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(profileProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar contraseña: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La contraseña debe tener al menos 8 caracteres, incluir mayúsculas, minúsculas, números y caracteres especiales.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contraseña actual
            AppPasswordField(
              controller: _currentPasswordController,
              label: 'Contraseña Actual',
              validator: (value) => Validators.required(value, fieldName: 'La contraseña actual'),
            ),
            const SizedBox(height: 16),

            // Nueva contraseña
            AppPasswordField(
              controller: _newPasswordController,
              label: 'Nueva Contraseña',
              validator: Validators.password,
            ),
            const SizedBox(height: 16),

            // Confirmar contraseña
            AppPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirmar Nueva Contraseña',
              validator: (value) => Validators.confirmPassword(value, _newPasswordController.text),
            ),
            const SizedBox(height: 24),

            // Botón de guardar
            AppFormSubmit(
              isLoading: _isLoading,
              onPressed: _handleSubmit,
              label: 'Cambiar Contraseña',
            ),
          ],
        ),
      ),
    );
  }
}
