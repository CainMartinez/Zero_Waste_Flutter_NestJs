import 'package:flutter/material.dart';
import 'package:eco_bocado/core/l10n/app_localizations.dart';
import '../../domain/entities/catalog_item.dart';

/// Card de producto/menú del catálogo
class ProductCard extends StatelessWidget {
  final CatalogItem item;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            AspectRatio(
              aspectRatio: 16 / 9,
              child: item.images.isNotEmpty
                  ? Image.network(
                      item.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tipo y badges
                    Row(
                      children: [
                        if (item.isMenu)
                          Chip(
                            label: Text(AppLocalizations.of(context)!.menuBadge, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        if (item.isVegan) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.eco, size: 16, color: Colors.green),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Nombre
                    Text(
                      item.name(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 2),
                    
                    // Descripción
                    Expanded(
                      child: Text(
                        item.description(context),
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Precio y botón
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${item.price.toStringAsFixed(2)} ${item.currency}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onAddToCart != null)
                          IconButton.filled(
                            onPressed: onAddToCart,
                            icon: const Icon(Icons.add_shopping_cart),
                            iconSize: 20,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        item.isMenu ? Icons.restaurant_menu : Icons.fastfood,
        size: 48,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
