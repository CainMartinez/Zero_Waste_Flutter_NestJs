import '../../../shop/domain/entities/catalog_item.dart';

/// Item del carrito con cantidad
class CartItem {
  final CatalogItem item;
  final int quantity;

  const CartItem({
    required this.item,
    required this.quantity,
  });

  CartItem copyWith({
    CatalogItem? item,
    int? quantity,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => item.price * quantity;
}

/// Estado del carrito
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}
