import 'package:flutter/material.dart';
import 'package:pub_diferent/catalog/widgets/showcase_scaffold.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';

class BadgesDemo extends StatelessWidget {
  const BadgesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcaseScaffold(
      title: 'Etiquetas',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('AppBadge', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text(
            'Chip informativo utilizado en FoodMenuCard (tags del plato) '
            'y OrderCard (estado del pedido).',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              AppBadge(label: 'Recomendado', color: Colors.blue),
              AppBadge(label: 'Zero Waste', color: Colors.green),
              AppBadge(label: 'Picante', color: Colors.red),
              AppBadge(
                label: 'Nuevo',
                color: Colors.amber,
                variant: AppBadgeVariant.outline,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Con iconos',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          const Text('Añade `icon` para estados con iconografía.'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              AppBadge(
                label: 'Preparando',
                color: Colors.blue,
                icon: Icons.restaurant,
              ),
              AppBadge(
                label: 'Listo',
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              AppBadge(
                label: 'Entrega',
                color: Colors.teal,
                icon: Icons.delivery_dining,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Tamaños', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          const Text('Controla el padding y la tipografía con `size`.'),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppBadge(
                label: 'Pequeño',
                color: Colors.deepPurple,
                size: AppBadgeSize.small,
              ),
              SizedBox(height: 8),
              AppBadge(
                label: 'Mediano',
                color: Colors.deepPurple,
                size: AppBadgeSize.medium,
              ),
              SizedBox(height: 8),
              AppBadge(
                label: 'Grande',
                color: Colors.deepPurple,
                size: AppBadgeSize.large,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
