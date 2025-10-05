import 'package:flutter/material.dart';

class AppTheme {
  static final TextTheme _textTheme = const TextTheme(
    headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),

    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

    bodyLarge: TextStyle(fontSize: 16, height: 1.4),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4),
    bodySmall: TextStyle(fontSize: 12, height: 1.4),

    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11, letterSpacing: 0.2),
  );

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4285F4),
    ).copyWith(
      primary: const Color(0xFF4285F4), // Azul
      secondary: const Color(0xFF34A853), // Verde
      error: const Color(0xFFEA4335), // Rojo
      surface: const Color(0xFFF5F5F5),
      onSurface: const Color(0xFF212121),
      onSurfaceVariant: const Color(0xFF757575),
    ),
    textTheme: _textTheme,
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4285F4),
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF4285F4), // Azul (marca)
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF5F5F5F),
      onPrimaryContainer: const Color(0xFFEDEDED),

      secondary: const Color(0xFF34A853), // Verde (marca)
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF5A5A5A),
      onSecondaryContainer: const Color(0xFFE6E6E6),

      error: const Color(0xFFEA4335),
      onError: Colors.white,

      // Fondo base en gris (no azul)
      surface: const Color(0xFF454545),
      onSurface: const Color(0xFFEAEAEA),
      onSurfaceVariant: const Color(0xFFBDBDBD),

      // Tonos “container” en gris para jerarquía visual
      surfaceContainerHighest: const Color(0xFF595959),
      surfaceContainer: const Color(0xFF505050),
      surfaceContainerLow: const Color(0xFF4B4B4B),

      // Bordes
      outline: const Color(0xFF6A6A6A),
      outlineVariant: const Color(0xFF5A5A5A),
    ),
    textTheme: _textTheme,
    cardTheme: const CardThemeData(
      elevation: 2,
      color: Color(0xFF3D3D3D), // Card en gris medio-oscuro
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF5A5A5A), // AppBar gris 
      elevation: 0,
    ),
  );
}