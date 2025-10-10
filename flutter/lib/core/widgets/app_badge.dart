import 'package:flutter/material.dart';

enum AppBadgeVariant { filled, outline }

enum AppBadgeSize { small, medium, large }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.variant = AppBadgeVariant.filled,
    this.size = AppBadgeSize.medium,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final AppBadgeVariant variant;
  final AppBadgeSize size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface;

    final (
      horizontalPadding,
      verticalPadding,
      fontSize,
      iconSize,
      gap,
    ) = switch (size) {
      AppBadgeSize.small => (8.0, 4.0, 10.0, 14.0, 4.0),
      AppBadgeSize.medium => (12.0, 6.0, 12.0, 16.0, 6.0),
      AppBadgeSize.large => (16.0, 8.0, 14.0, 18.0, 8.0),
    };

    final outline = variant == AppBadgeVariant.outline;
    final backgroundColor = _badgeBackgroundColor(
      base: baseColor,
      surface: surface,
      isOutlined: outline,
      isDark: isDark,
    );
    final foregroundColor = _badgeForegroundColor(
      base: baseColor,
      isOutlined: outline,
      isDark: isDark,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          size == AppBadgeSize.small ? 10 : 12,
        ),
        border: outline ? Border.all(color: baseColor, width: 1.4) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: iconSize, color: foregroundColor),
          if (icon != null) SizedBox(width: gap),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

Color _badgeBackgroundColor({
  required Color base,
  required Color surface,
  required bool isOutlined,
  required bool isDark,
}) {
  if (isOutlined) return Colors.transparent;
  final overlayOpacity = isDark ? 0.38 : 0.18;
  return Color.alphaBlend(base.withValues(alpha: overlayOpacity), surface);
}

Color _badgeForegroundColor({
  required Color base,
  required bool isOutlined,
  required bool isDark,
}) {
  if (isOutlined) return base;
  final target = isDark ? Colors.white : Colors.black87;
  return Color.lerp(base, target, isDark ? 0.6 : 0.4)!;
}
