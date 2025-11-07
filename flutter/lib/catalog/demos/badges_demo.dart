import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';

class BadgesDemo extends StatelessWidget {
  const BadgesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ShowcaseScaffold(
      title: 'Etiquetas',
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
                  _buildUsageItem(
                    theme,
                    'Home: Badges en hero header y loyalty banner',
                  ),
                  _buildUsageItem(
                    theme,
                    'Shop: FoodMenuCard - tags de platos (Recomendado, Zero Waste, etc.)',
                  ),
                  _buildUsageItem(
                    theme,
                    'Orders: OrderCard - estado del pedido (Preparando, Listo, etc.)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          
          // AppBadge
          Text(
            'AppBadge',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'core/widgets/app_badge.dart',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Etiqueta reutilizable con variantes filled y outline. '
            'Integrado con el theme para colores consistentes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 16),
          Text(
            'Variante Filled',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(
                label: 'Recomendado',
                color: theme.colorScheme.primary,
              ),
              AppBadge(
                label: 'Zero Waste',
                color: theme.colorScheme.secondary,
              ),
              AppBadge(
                label: 'Picante',
                color: theme.colorScheme.error,
              ),
              AppBadge(
                label: 'Premium',
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFFFFB74D)
                    : Colors.amber,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Variante Outline',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(
                label: 'Nuevo',
                color: theme.colorScheme.primary,
                variant: AppBadgeVariant.outline,
              ),
              AppBadge(
                label: 'Oferta',
                color: theme.colorScheme.secondary,
                variant: AppBadgeVariant.outline,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Con iconos',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Usado en OrderCard para mostrar estados del pedido',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadge(
                label: 'Preparando',
                color: theme.colorScheme.primary,
                icon: Icons.restaurant,
              ),
              AppBadge(
                label: 'Listo',
                color: theme.colorScheme.secondary,
                icon: Icons.check_circle,
              ),
              AppBadge(
                label: 'Entrega',
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF4DB6AC)
                    : Colors.teal,
                icon: Icons.delivery_dining,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Tamaños',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AppBadgeSize.small usado en FoodMenuCard y OrderCard',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBadge(
                label: 'Small',
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF9575CD)
                    : Colors.deepPurple,
                size: AppBadgeSize.small,
              ),
              const SizedBox(height: 8),
              AppBadge(
                label: 'Medium',
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF9575CD)
                    : Colors.deepPurple,
                size: AppBadgeSize.medium,
              ),
              const SizedBox(height: 8),
              AppBadge(
                label: 'Large',
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF9575CD)
                    : Colors.deepPurple,
                size: AppBadgeSize.large,
              ),
            ],
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
