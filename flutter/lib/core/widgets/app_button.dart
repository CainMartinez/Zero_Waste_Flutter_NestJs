import 'package:flutter/material.dart';
import 'package:eco_bocado/app/theme/app_palette.dart';

enum AppButtonVariant { primary, secondary, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Overrides opcionales por si queremos forzar colores puntuales.
  final Color? backgroundColorOverride;
  final Color? foregroundColorOverride;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.backgroundColorOverride,
    this.foregroundColorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final palette = appPaletteOf(context);

    final (bg, fg) = switch (variant) {
      AppButtonVariant.primary => (palette.primary, palette.onPrimary),
      AppButtonVariant.secondary => (palette.secondary, palette.onSecondary),
      AppButtonVariant.danger => (palette.danger, palette.onDanger),
    };

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColorOverride ?? bg,
        foregroundColor: foregroundColorOverride ?? fg,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
