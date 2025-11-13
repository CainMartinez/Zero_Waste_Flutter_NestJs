import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_state.dart';
import '../../../shop/domain/entities/catalog_item.dart';

/// Notificador del carrito
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// Añade un item al carrito o incrementa su cantidad
  void addItem(CatalogItem item) {
    final existingIndex = state.items.indexWhere((cartItem) => cartItem.item.id == item.id);

    if (existingIndex >= 0) {
      // Incrementar cantidad
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + 1,
      );
      state = state.copyWith(items: updatedItems);
    } else {
      // Añadir nuevo item
      state = state.copyWith(
        items: [...state.items, CartItem(item: item, quantity: 1)],
      );
    }
  }

  /// Elimina una unidad del item o lo quita del carrito si quantity = 1
  void removeItem(int itemId) {
    final existingIndex = state.items.indexWhere((cartItem) => cartItem.item.id == itemId);

    if (existingIndex >= 0) {
      final currentQuantity = state.items[existingIndex].quantity;
      
      if (currentQuantity > 1) {
        // Decrementar cantidad
        final updatedItems = List<CartItem>.from(state.items);
        updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
          quantity: currentQuantity - 1,
        );
        state = state.copyWith(items: updatedItems);
      } else {
        // Eliminar del carrito
        final updatedItems = List<CartItem>.from(state.items)..removeAt(existingIndex);
        state = state.copyWith(items: updatedItems);
      }
    }
  }

  /// Elimina completamente un item del carrito
  void deleteItem(int itemId) {
    final updatedItems = state.items.where((cartItem) => cartItem.item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  /// Limpia el carrito
  void clear() {
    state = const CartState();
  }
}

/// Provider del carrito
final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

/// Provider solo del contador de items (para el badge)
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});
