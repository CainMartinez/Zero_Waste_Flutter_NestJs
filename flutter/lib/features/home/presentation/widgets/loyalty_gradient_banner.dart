import 'package:flutter/material.dart';
import 'package:eco_bocado/core/widgets/app_badge.dart';

/// Banner con gradiente cálido para promociones de fidelidad.
class LoyaltyGradientBanner extends StatelessWidget {
  const LoyaltyGradientBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.showNewBadge = true,
    this.padding,
  });

  /// Título principal (línea superior, en negrita).
  final String title;

  /// Subtítulo o línea descriptiva.
  final String subtitle;

  /// Muestra u oculta el badge “NUEVO!”.
  final bool showNewBadge;

  /// Padding interno opcional.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    // Gradiente cálido estilo promo. Usamos una mezcla entre
    // tonos “ámbar/naranja” y el secundario del tema para que
    // se vea bien tanto en claro como oscuro.
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        // Warm start
        const Color(0xFFFFC107).withValues(alpha: isDark ? 0.90 : 0.88), // Amber
        const Color(0xFFFF7043).withValues(alpha: isDark ? 0.95 : 0.92), // Deep orange
        // Blend with theme secondary at el final para coherencia de marca
        cs.secondary.withValues(alpha: isDark ? 0.92 : 0.90),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono “regalo” en un tile sutil para jerarquía visual
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Títulos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila con título y badge NUEVO (opcional)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: tt.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (showNewBadge) ...[
                      const SizedBox(width: 8),
                      const AppBadge(
                        label: '¡NUEVO!',
                        icon: Icons.bolt,
                        // badge ya gestiona contraste; aquí forzamos color vivo
                        color: Colors.white,
                        variant: AppBadgeVariant.outline,
                        size: AppBadgeSize.small,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}