# 🛒 MÓDULO CART - Carrito de Compras

---

## 📝 Descripción del Carrito

El **módulo Cart** gestiona el carrito de compras de la aplicación. Es un módulo **completamente local** (sin persistencia en backend) que utiliza Riverpod para mantener el estado en memoria durante la sesión.

### Características Principales

- ✅ **Estado Local**: El carrito se mantiene en memoria (Riverpod Notifier)
- 🛍️ **Gestión de Cantidades**: Incrementar/decrementar cantidad de cada item
- 💰 **Cálculo Automático**: Subtotales, total de items y precio total
- 🗑️ **Eliminar Items**: Botón para quitar items individuales o vaciar todo
- 🎨 **UI Moderna**: Cards con imágenes, información completa y controles intuitivos
- 📱 **Responsive**: Vista de lista con resumen sticky en la parte inferior
- ⚠️ **Estado Vacío**: Mensaje y botón para volver al menú cuando no hay items

### Tecnologías Utilizadas

- **Riverpod 3.0**: `Notifier` para estado del carrito
- **State Management Local**: Sin persistencia (se pierde al cerrar la app)
- **Material Design 3**: Cards, FilledButton, outlined buttons

---

## 🏗️ Arquitectura del Módulo Cart

```
cart/
├── domain/                        # Capa de Dominio
│   └── models/
│       └── cart_state.dart        # CartState y CartItem
│
└── presentation/                  # Capa de Presentación
    ├── pages/
    │   └── cart_page.dart         # Página del carrito
    └── providers/
        └── cart_provider.dart     # Provider del carrito (Notifier)
```

**Nota**: El módulo Cart NO tiene capa de datos porque es completamente local.

### Flujo de Datos

```
Usuario interactúa con UI
        ↓
    CartPage
        ↓
    cartProvider.addItem() / removeItem()
        ↓
    CartNotifier actualiza CartState
        ↓
    UI se re-renderiza automáticamente (Riverpod)
```

---

## 📱 CartPage - Página Principal

### Código Principal

```dart
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
}
```

### Características Clave

#### 1. **Estado Vacío**

```dart
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
```

**Características**:
- Icono grande semi-transparente
- Mensaje amigable
- Botón para volver al menú (shop)

---

#### 2. **Lista de Items**

```dart
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
```

**Layout**:
- **Expanded ListView**: Scrolleable si hay muchos items
- **Separadores**: Dividers entre cada item
- **CartSummary sticky**: Siempre visible en la parte inferior

---

#### 3. **Card de Item**

```dart
Widget _buildCartItemCard(BuildContext context, WidgetRef ref, CartItem cartItem) {
  return Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen del producto (80x80)
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
                      Icon(Icons.eco, size: 16, color: Colors.green),
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
```

**Elementos**:
- **Imagen**: 80x80px con border radius
- **Nombre**: Máximo 2 líneas con ellipsis
- **Categoría**: Color primary para destacar
- **Precio unitario**: Precio del item individual
- **Badge vegano**: Icono eco si es vegano
- **Controles de cantidad**: Botones +/-
- **Precio total**: Precio × cantidad

---

#### 4. **Controles de Cantidad**

```dart
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
```

**Lógica inteligente**:
- **Botón menos**: 
  - Si `quantity > 1` → Muestra icono `remove` (decrementa)
  - Si `quantity == 1` → Muestra icono `delete` en color rojo (elimina del carrito)
- **Botón más**: Siempre incrementa cantidad
- **Display central**: Muestra la cantidad actual

---

#### 5. **Resumen del Carrito (Sticky Bottom)**

```dart
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
          // Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: Theme.of(context).textTheme.bodyLarge),
              Text(
                '${cartState.totalPrice.toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Total de artículos
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
          
          // Total final
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
```

**Características**:
- **Sombra superior**: Efecto de elevación
- **SafeArea**: Respeta notch/indicadores de sistema
- **Resumen detallado**: Subtotal, cantidad de items, total
- **Botón principal**: Ocupa todo el ancho, altura cómoda (16px vertical padding)

---

#### 6. **Diálogo de Vaciar Carrito**

```dart
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
```

**UX**:
- Confirmación antes de vaciar
- Botón de acción destructiva en rojo
- Cierra el diálogo automáticamente tras vaciar

---

## 🔄 CartProvider - Estado del Carrito

```dart
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

final cartProvider = NotifierProvider<CartNotifier, CartState>(() {
  return CartNotifier();
});

/// Provider solo del contador de items (para el badge)
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});
```

### Métodos Públicos

| Método | Descripción | Comportamiento |
|--------|-------------|----------------|
| `addItem(item)` | Añade item o incrementa cantidad | Si existe: +1, Si no: añadir nuevo |
| `removeItem(itemId)` | Decrementa o elimina | Si quantity > 1: -1, Si quantity == 1: eliminar |
| `deleteItem(itemId)` | Elimina completamente | Quita el item sin importar quantity |
| `clear()` | Vacía el carrito | Resetea a estado inicial vacío |

### Provider Derivado

```dart
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});
```

**Uso**: Badge en el icono del carrito en ShopPage AppBar
```dart
if (cartItemCount > 0)
  Positioned(
    right: 8,
    top: 8,
    child: Container(
      child: Text('$cartItemCount'),
    ),
  ),
```

---

## 📦 Modelos del Carrito

### CartItem

```dart
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
```

**Campos**:
- `item`: El producto/menú completo (de CatalogItem del módulo Shop)
- `quantity`: Cantidad de unidades de este item
- `totalPrice`: Getter calculado (precio × cantidad)

---

### CartState

```dart
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}
```

**Getters calculados**:
- `totalItems`: Suma de todas las cantidades
  - Ejemplo: [item1(qty:2), item2(qty:3)] → `totalItems = 5`
- `totalPrice`: Suma de todos los subtotales
  - Ejemplo: [item1(€10×2), item2(€5×3)] → `totalPrice = €35`

---

### Cart
✅ **Estado local eficiente** con Riverpod  
✅ **UX intuitiva** con controles +/- inteligentes  
✅ **Cálculos automáticos** de totales y cantidades  
✅ **UI responsive** con resumen sticky  
✅ **Sin dependencias** (completamente independiente)  