import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_button.dart';

/// Barra inferior con llamada a la acción primaria.
class PrimaryCtaBar extends StatelessWidget {
  const PrimaryCtaBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  /// Texto del botón.
  final String label;

  /// Acción a ejecutar.
  final VoidCallback onPressed;

  /// Variante del botón (primary, secondary, danger).
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: label,
          onPressed: onPressed,
          variant: variant,
        ),
      ),
    );
  }
}