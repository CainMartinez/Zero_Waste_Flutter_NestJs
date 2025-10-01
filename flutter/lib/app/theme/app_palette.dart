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

/// Paleta para tema claro
const appPaletteLight = AppPalette(
  primary: Color(0xFF0057D9),
  onPrimary: Colors.white,
  secondary: Color(0xFF0B874B),
  onSecondary: Colors.white,
  danger: Color(0xFFD92D20),
  onDanger: Colors.white,
);

/// Paleta para tema oscuro (ajusta los contrastes)
const appPaletteDark = AppPalette(
  primary: Color(0xFF7BA7FF),
  onPrimary: Color(0xFF0B0B0B),
  secondary: Color(0xFF6CD09A),
  onSecondary: Color(0xFF0B0B0B),
  danger: Color(0xFFFF7A6E),
  onDanger: Color(0xFF0B0B0B),
);

/// Devuelve la paleta adecuada según el brillo del tema activo.
AppPalette appPaletteOf(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? appPaletteDark : appPaletteLight;
}
