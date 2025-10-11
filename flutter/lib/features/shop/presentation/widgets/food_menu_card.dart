import 'package:flutter/material.dart';
import 'package:pub_diferent/core/widgets/app_badge.dart';

/// Tarjeta de menú para mostrar platos individuales dentro del listado principal
class FoodMenuCard extends StatelessWidget {
  const FoodMenuCard({
    super.key,
    required this.dishName,
    required this.description,
    required this.price,
    this.imageUrl,
    this.badges = const [],
    this.isAvailable = true,
    this.onTap,
  });

  final String dishName;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> badges;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DishThumbnail(imageUrl: imageUrl, isAvailable: isAvailable),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dishName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: badges
                            .map(
                              (badge) => AppBadge(
                                label: badge,
                                color: _badgeColorForLabel(
                                  context: context,
                                  badge: badge,
                                ),
                                size: AppBadgeSize.small,
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '€${price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        if (isAvailable)
                          FilledButton.icon(
                            onPressed: onTap,
                            icon: const Icon(Icons.add),
                            label: const Text('Añadir'),
                          ),
                        if (!isAvailable)
                          AppBadge(
                            label: 'No disponible',
                            color: colorScheme.error,
                            variant: AppBadgeVariant.outline,
                            size: AppBadgeSize.small,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DishThumbnail extends StatelessWidget {
  const _DishThumbnail({required this.imageUrl, required this.isAvailable});

  final String? imageUrl;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackColor = theme.colorScheme.surfaceContainerHighest;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: fallbackColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _FallbackIcon(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            _FallbackIcon(color: theme.colorScheme.onSurfaceVariant),
          if (!isAvailable)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(
                'AGOTADO',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.restaurant, size: 32, color: color);
  }
}

Color _badgeColorForLabel({
  required BuildContext context,
  required String badge,
}) {
  final lower = badge.toLowerCase();
  final palette = Theme.of(context).colorScheme;

  if (lower.contains('zero waste') || lower.contains('eco')) {
    return Colors.green;
  }
  if (lower.contains('vegano') || lower.contains('vegetariano')) {
    return Colors.lightGreen;
  }
  if (lower.contains('picante')) {
    return Colors.red;
  }
  if (lower.contains('nuevo')) {
    return Colors.amber;
  }
  return palette.secondary;
}
