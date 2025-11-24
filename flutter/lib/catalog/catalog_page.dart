import 'package:flutter/material.dart';
import 'package:eco_bocado/catalog/demos/buttons_demo.dart';
import 'package:eco_bocado/catalog/demos/cards_demo.dart';
import 'package:eco_bocado/catalog/demos/inputs_demo.dart';
import 'package:eco_bocado/catalog/demos/badges_demo.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Componentes'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de información
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sistema de Diseño',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Componentes reutilizables de la aplicación. Todos están integrados '
                    'con el sistema de temas y se usan en múltiples pantallas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Título de sección
          Text(
            'Componentes Core',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Widgets base reutilizados en toda la aplicación',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de componentes
          _ComponentCard(
            title: 'Botones',
            subtitle: 'AppButton',
            description: 'Usado en: Home, Auth (login/register), Orders',
            icon: Icons.smart_button,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ButtonsDemo()),
            ),
          ),
          
          _ComponentCard(
            title: 'Campos de Formulario',
            subtitle: 'AppTextField, AppPasswordField',
            description: 'Usado en: Login, Register, Profile, Settings',
            icon: Icons.input,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InputsDemo()),
            ),
          ),
          
          _ComponentCard(
            title: 'Etiquetas y Badges',
            subtitle: 'AppBadge',
            description: 'Usado en: Orders (estados), Shop (categorías)',
            icon: Icons.label,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BadgesDemo()),
            ),
          ),
          
          _ComponentCard(
            title: 'Tarjetas',
            subtitle: 'Cards personalizadas',
            description: 'Usado en: Home, Shop, Orders',
            icon: Icons.card_membership,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CardsDemo()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ComponentCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
