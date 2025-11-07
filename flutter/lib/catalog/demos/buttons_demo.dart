import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/core/widgets/app_button.dart';
import 'package:pub_diferent/core/widgets/app_form_submit.dart';

class ButtonsDemo extends StatelessWidget {
  const ButtonsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ShowcaseScaffold(
      title: 'Botones',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de uso en la app
          _UsageSection(
            theme: theme,
            locations: [
              'Home: Botones de navegación',
              'Auth: Login y Register forms',
              'Orders: Confirmar pedido',
              'Profile: Guardar cambios',
            ],
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // AppButton
          _ComponentSection(
            theme: theme,
            title: 'AppButton',
            subtitle: 'core/widgets/app_button.dart',
            description: 'Botón principal reutilizable con variantes primary y danger. '
                'Integrado con el theme para colores y estilos consistentes.',
          ),
          
          const SizedBox(height: 16),
          AppButton(
            label: 'Primary Button',
            onPressed: () {},
            variant: AppButtonVariant.primary,
          ),
          
          const SizedBox(height: 12),
          AppButton(
            label: 'Danger Button',
            onPressed: () {},
            variant: AppButtonVariant.danger,
          ),
          
          const SizedBox(height: 12),
          AppButton(
            label: 'Disabled Button',
            onPressed: null,
            variant: AppButtonVariant.primary,
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // AppFormSubmit
          _ComponentSection(
            theme: theme,
            title: 'AppFormSubmit',
            subtitle: 'core/widgets/app_form_submit.dart',
            description: 'Botón especializado para formularios con estado de carga. '
                'Usado en login_form.dart y register_form.dart',
          ),
          
          const SizedBox(height: 16),
          AppFormSubmit(
            label: 'Iniciar sesión',
            onPressed: () {},
            isLoading: false,
          ),
          
          const SizedBox(height: 12),
          const AppFormSubmit(
            label: 'Creando cuenta...',
            onPressed: null,
            isLoading: true,
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // Composición
          Text(
            'Composición en layouts',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Responsive con Expanded',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Aceptar',
                  onPressed: () {},
                  variant: AppButtonVariant.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Cancelar',
                  onPressed: () {},
                  variant: AppButtonVariant.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  final ThemeData theme;
  final List<String> locations;

  const _UsageSection({
    required this.theme,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
            ...locations.map((location) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ComponentSection extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String subtitle;
  final String description;

  const _ComponentSection({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}