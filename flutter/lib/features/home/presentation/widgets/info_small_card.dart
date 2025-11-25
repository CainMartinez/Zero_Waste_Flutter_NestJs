import 'package:flutter/material.dart';

/// Card pequeña informativa usada en el home.
class InfoSmallCard extends StatelessWidget {
  const InfoSmallCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
  });

  /// Icono principal (Material icon).
  final IconData icon;

  /// Título corto (ej. “Zero Waste”).
  final String title;

  /// Subtítulo (ej. “Sin desperdicios”).
  final String subtitle;

  /// Color base opcional para el icono (por defecto usa `colorScheme.secondary`).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Card(
      elevation: 2,
      color: cs.surfaceContainer, // gris en modo oscuro, claro en light
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono circular decorativo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (color ?? cs.secondary).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color ?? cs.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}