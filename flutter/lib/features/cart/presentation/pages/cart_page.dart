import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_state.dart';
import '../providers/cart_provider.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(context, ref),
              tooltip: 'Vaciar carrito',
            ),
        ],
      ),
      body: cartState.items.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, ref, cartState),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade productos desde el menú',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.restaurant_menu),
            label: const Text('Ver Menú'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, WidgetRef ref, CartState cartState) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cartState.items.length,
            separatorBuilder: (context, index) => const Divider(height: 24),
            itemBuilder: (context, index) {
              final cartItem = cartState.items[index];
              return _buildCartItemCard(context, ref, cartItem);
            },
          ),
        ),
        _buildCartSummary(context, ref, cartState),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, WidgetRef ref, CartItem cartItem) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cartItem.item.images.isNotEmpty
                  ? Image.network(
                      cartItem.item.images.first,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderImage(context, cartItem),
                    )
                  : _buildPlaceholderImage(context, cartItem),
            ),
            const SizedBox(width: 12),
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.item.nameEs,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.item.category.nameEs,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${cartItem.item.price.toStringAsFixed(2)} ${cartItem.item.currency}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (cartItem.item.isVegan) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.eco,
                          size: 16,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Controles de cantidad
            Column(
              children: [
                _buildQuantityControls(context, ref, cartItem),
                const SizedBox(height: 8),
                Text(
                  '${cartItem.totalPrice.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context, CartItem cartItem) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        cartItem.item.isMenu ? Icons.restaurant_menu : Icons.fastfood,
        size: 32,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, WidgetRef ref, CartItem cartItem) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              cartItem.quantity > 1 ? Icons.remove : Icons.delete_outline,
              size: 18,
            ),
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(cartItem.item.id);
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: cartItem.quantity > 1
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.error,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '${cartItem.quantity}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () {
              ref.read(cartProvider.notifier).addItem(cartItem.item);
            },
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, WidgetRef ref, CartState cartState) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Resumen de precios
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${cartState.totalPrice.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total de artículos',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  '${cartState.totalItems}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${cartState.totalPrice.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Botón confirmar pedido
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // TODO: Implementar confirmación de pedido
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Función de pedido pendiente de implementar'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Confirmar Pedido'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Estás seguro de que deseas eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}
