import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/core/widgets/app_text_field.dart';
import 'package:pub_diferent/core/widgets/app_password_field.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';

class InputsDemo extends StatefulWidget {
  const InputsDemo({super.key});

  @override
  State<InputsDemo> createState() => _InputsDemoState();
}

class _InputsDemoState extends State<InputsDemo> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ShowcaseScaffold(
      title: 'Campos de Formulario',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de uso en la app
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Usado en la aplicación',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildUsageItem(theme, 'Auth: login_form.dart - email y contraseña'),
                  _buildUsageItem(theme, 'Auth: register_form.dart - nombre, email y contraseña'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // AppTextField
          Text(
            'AppTextField',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'core/widgets/app_text_field.dart',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Campo de texto reutilizable con validación integrada. '
            'Usado en formularios de login y registro.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          AppTextField(
            controller: _emailController,
            label: 'Correo electrónico',
            hint: 'ejemplo@email.com',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El correo es requerido';
              }
              if (!value.contains('@')) {
                return 'Ingresa un correo válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // AppPasswordField
          Text(
            'AppPasswordField',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'core/widgets/app_password_field.dart',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Campo especializado para contraseñas con toggle de visibilidad. '
            'Usado en login_form.dart y register_form.dart.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          AppPasswordField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 8) {
                return 'Mínimo 8 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // Ejemplo de formulario completo
          Text(
            'Ejemplo de uso completo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Composición como en login_form.dart',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          AppFormSubmit(
            label: _isLoading ? 'Iniciando sesión...' : 'Iniciar sesión',
            onPressed: _isLoading ? null : () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _isLoading = false);
              });
            },
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
