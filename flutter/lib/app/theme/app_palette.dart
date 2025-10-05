import 'package:flutter/material.dart';

class AppPalette {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color danger;
  final Color onDanger;

  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.danger,
    required this.onDanger,
  });
}

/// Paleta para tema claro (marca)
const appPaletteLight = AppPalette(
  primary: Color(0xFF4285F4), // Azul
  onPrimary: Colors.white,
  secondary: Color(0xFF34A853), // Verde
  onSecondary: Colors.white,
  danger: Color(0xFFEA4335), // Rojo
  onDanger: Colors.white,
);

/// Paleta para tema oscuro (marca) — superficies se toman del ThemeData oscuro en gris
const appPaletteDark = AppPalette(
  primary: Color(0xFF4285F4),
  onPrimary: Colors.white,
  secondary: Color(0xFF34A853),
  onSecondary: Colors.white,
  danger: Color(0xFFEA4335),
  onDanger: Colors.white,
);

/// Devuelve la paleta adecuada según el brillo del tema activo.
AppPalette appPaletteOf(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? appPaletteDark : appPaletteLight;
}