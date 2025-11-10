import 'package:flutter/material.dart';

/// Chip de filtro reutilizable con estilo consistente
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: 16,
              color: selected && icon == Icons.eco
                  ? Colors.green.shade800 // Hoja verde oscura siempre visible
                  : null,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected && icon == Icons.eco
                  ? Colors.green.shade900 // Texto oscuro sobre fondo verde
                  : null,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: icon == Icons.eco && selected
          ? Colors.green.shade200 // Fondo verde claro para vegano
          : Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: icon == Icons.eco && selected
          ? Colors.green.shade800
          : Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: selected
            ? (icon == Icons.eco ? Colors.green : Theme.of(context).colorScheme.primary)
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
