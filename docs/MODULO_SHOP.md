# 🛍️ MÓDULO SHOP

---

## 📝 Descripción General

El **módulo Shop** es el módulo más complejo de la aplicación. Implementa un **catálogo unificado** de productos y menús con un sistema avanzado de filtrado, paginación infinita y gestión de estado mediante Riverpod.

### Características Principales

- ✅ **Catálogo Unificado**: Combina productos individuales y menús de rescate en un solo listado
- 🔍 **Sistema de Filtros Avanzado**: 
  - Por categoría (Entrantes, Principales, Bebidas, Postres, Menús)
  - Por alérgenos (filtrado inverso: excluye productos con alérgenos seleccionados)
  - Por tipo (Solo vegano)
  - Por orden (precio, nombre, fecha)
- 📄 **Paginación Infinita**: Scroll infinito con cursor-based pagination
- 🛒 **Integración con Carrito**: Añadir productos directamente desde el catálogo
- 📱 **Modal Detallado**: Vista completa con carrusel de imágenes, ingredientes y alérgenos

### Tecnologías Utilizadas

- **Riverpod 3.0**: State management con `Notifier` para el catálogo
- **Dio**: Cliente HTTP para llamadas a la API
- **Clean Architecture**: Separación en capas `data`, `domain`, `presentation`
- **Cursor Pagination**: Paginación eficiente basada en IDs
- **Modal Bottom Sheets**: Filtros y detalles en modales nativos de Flutter

---

## 🏗️ Arquitectura del Módulo

El módulo Shop sigue la **Clean Architecture** con separación clara de responsabilidades:

```
shop/
├── data/                          # Capa de Datos
│   ├── datasources/
│   │   └── shop_api_client.dart   # Cliente API con Dio
│   └── repositories/
│       └── shop_repository_impl.dart  # Implementación del repositorio
│
├── domain/                        # Capa de Dominio
│   ├── entities/                  # Entidades del dominio
│   │   ├── catalog_item.dart      # Item unificado (Product/Menu)
│   │   ├── catalog_filters.dart   # Filtros de búsqueda
│   │   ├── catalog_state.dart     # Estado del catálogo
│   │   ├── paginated_catalog.dart # Resultado paginado
│   │   ├── category.dart          # Categoría de producto
│   │   └── allergen.dart          # Alérgeno
│   ├── repositories/
│   │   └── shop_repository.dart   # Interface del repositorio
│   └── usecases/                  # Casos de uso
│       ├── get_catalog_usecase.dart
│       ├── get_allergens_usecase.dart
│       └── get_categories_usecase.dart
│
└── presentation/                  # Capa de Presentación
    ├── pages/
    │   └── shop_page.dart         # Página principal del catálogo
    ├── providers/
    │   └── catalog_provider.dart  # Providers de Riverpod
    └── widgets/
        ├── product_card.dart      # Card de producto en grid
        ├── product_detail_modal.dart  # Modal de detalles
        └── food_menu_card.dart    # Card específico de menú
```

### Flujo de Datos

```
Usuario interactúa con UI
        ↓
    ShopPage
        ↓
    catalogProvider (Riverpod Notifier)
        ↓
    GetCatalogUseCase
        ↓
    ShopRepository (interface)
        ↓
    ShopRepositoryImpl
        ↓
    ShopApiClient (Dio)
        ↓
    Backend API (NestJS)
        ↓
    Respuesta → Entities → State → UI
```

---

## 📱 ShopPage - Página Principal

### Descripción

`ShopPage` es un **ConsumerStatefulWidget** que implementa el catálogo completo con filtros interactivos y scroll infinito. Es la página más compleja del proyecto, gestionando múltiples estados y filtros simultáneamente.

### Estructura de la Clase

```dart
class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  final ScrollController _scrollController = ScrollController();
  
  // Estado de filtros
  String? _selectedCategory;
  bool? _isVegan;
  List<String> _excludedAllergens = [];
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Carga inicial después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalog();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ... métodos de la clase
}
```

### Características Clave

#### 1. **Gestión de Estado Local**

```dart
// Variables de estado para filtros
String? _selectedCategory;      // Código de categoría seleccionada
bool? _isVegan;                 // null = todos, true = solo veganos
List<String> _excludedAllergens = [];  // Códigos de alérgenos a excluir
String _sortBy = 'createdAt';   // Campo de ordenación
String _sortOrder = 'desc';     // Dirección de ordenación
```

**¿Por qué estado local y no provider?**
- Los filtros son específicos de esta página
- No necesitan compartirse con otras vistas
- Mejor performance al no propagar cambios innecesarios
- Permite reset rápido sin afectar otros módulos

#### 2. **Scroll Infinito**

```dart
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    // Cuando está a 200px del final, cargar más
    ref.read(catalogProvider.notifier).loadMore();
  }
}
```

**Detalles de implementación**:
- Detecta cuando el usuario está cerca del final (200px antes)
- Llama a `loadMore()` del provider para cargar la siguiente página
- El provider controla si ya está cargando para evitar duplicados
- Usa `nextCursor` del backend para cursor-based pagination

#### 3. **Carga Inicial**

```dart
@override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  
  // Esperar al primer frame antes de cargar
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadCatalog();
  });
}
```

**¿Por qué `addPostFrameCallback`?**
- El provider aún no está completamente inicializado en `initState`
- Espera a que el widget tree esté construido
- Evita errores de "provider not yet initialized"
- Patrón estándar en Riverpod para cargas iniciales

#### 4. **Método de Carga de Catálogo**

```dart
void _loadCatalog() {
  final filters = CatalogFilters(
    categoryCode: _selectedCategory,
    isVegan: _isVegan,
    excludeAllergens: _excludedAllergens.isEmpty ? null : _excludedAllergens,
    sortBy: _sortBy,
    sortOrder: _sortOrder,
    limit: 20,  // Items por página
  );
  ref.read(catalogProvider.notifier).loadCatalog(filters);
}
```

**Responsabilidades**:
- Construye el objeto `CatalogFilters` con los valores actuales
- Pasa `null` para `excludeAllergens` si está vacío (optimización de query)
- Usa `limit: 20` para controlar items por página
- Llama al notifier con `loadCatalog` (reinicia el catálogo desde cero)

### AppBar y Acciones

```dart
appBar: AppBar(
  title: const Text('Disfruta la comida Zero Waste'),
  actions: [
    // Botón de ordenar
    IconButton(
      icon: const Icon(Icons.sort),
      onPressed: _showSortOptions,
    ),
    // Carrito con badge de cantidad
    Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CartPage(),
              ),
            );
          },
        ),
        if (cartItemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                '$cartItemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    ),
    const SizedBox(width: 8),
  ],
),
```

**Elementos destacados**:
- **Badge de carrito**: Muestra cantidad de items con `cartItemCountProvider`
- **Botón de ordenar**: Abre modal con opciones de sort
- **Título descriptivo**: Refuerza el mensaje Zero Waste de la app

---

## 🔍 Sistema de Filtros

El sistema de filtros es uno de los aspectos más sofisticados del módulo Shop. Permite combinaciones complejas y sincronización con el backend.

### Filtros Disponibles

| Filtro | Tipo | Valores | Comportamiento |
|--------|------|---------|----------------|
| **Categoría** | Select único | `null`, `ENTRANTES`, `PRINCIPALES`, etc. | Filtra por categoría específica o muestra todas |
| **Vegano** | Toggle | `null`, `true` | `null` = todos, `true` = solo veganos |
| **Alérgenos** | Multi-select | Array de códigos | **INVERSO**: Excluye productos que contengan estos alérgenos |
| **Ordenar por** | Select único | `price`, `name`, `createdAt` | Campo de ordenación |
| **Orden** | Select único | `asc`, `desc` | Dirección ascendente o descendente |

### 1. Filtro de Categoría

```dart
void _showCategorySelector(AsyncValue<List<Category>> categoriesAsync) {
  categoriesAsync.when(
    data: (categories) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.67,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              ListTile(
                title: const Text('Seleccionar Categoría'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Opción "Todas"
                    ListTile(
                      title: const Text('Todas'),
                      trailing: _selectedCategory == null 
                        ? const Icon(Icons.check) 
                        : null,
                      selected: _selectedCategory == null,
                      onTap: () {
                        setState(() => _selectedCategory = null);
                        Navigator.pop(context);
                        _loadCatalog();
                      },
                    ),
                    // Lista de categorías
                    ...categories.map((category) => ListTile(
                      title: Text(category.nameEs),
                      trailing: _selectedCategory == category.code 
                        ? const Icon(Icons.check) 
                        : null,
                      selected: _selectedCategory == category.code,
                      onTap: () {
                        setState(() => _selectedCategory = category.code);
                        Navigator.pop(context);
                        _loadCatalog();
                      },
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
    loading: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando categorías...')),
      );
    },
    error: (error, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar categorías: $error')),
      );
    },
  );
}
```

**Características**:
- **DraggableScrollableSheet**: Modal arrastrable para mejor UX
- **AsyncValue pattern**: Maneja estados loading/error/data de categorías
- **Opción "Todas"**: Resetea el filtro (`null`)
- **Checkmark visual**: Indica la categoría seleccionada
- **Recarga automática**: Llama `_loadCatalog()` al cambiar

### 2. Filtro de Alérgenos (Multi-Select)

```dart
void _showAllergenSelector(AsyncValue<List<Allergen>> allergensAsync) {
  allergensAsync.when(
    data: (allergens) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => StatefulBuilder(
          builder: (context, setModalState) => DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.4,
            maxChildSize: 1,
            expand: false,
            builder: (context, scrollController) => Column(
              children: [
                ListTile(
                  title: const Text('Selecciona las alergias para tu seguridad'),
                  subtitle: Text(_excludedAllergens.isEmpty 
                    ? 'Ninguno seleccionado' 
                    : '${_excludedAllergens.length} seleccionados'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_excludedAllergens.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() => _excludedAllergens.clear());
                            setModalState(() {});
                            _loadCatalog();
                          },
                          child: const Text('Limpiar'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: allergens.length,
                    itemBuilder: (context, index) {
                      final allergen = allergens[index];
                      final isSelected = _excludedAllergens.contains(allergen.code);
                      return CheckboxListTile(
                        title: Text(allergen.nameEs),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _excludedAllergens.add(allergen.code);
                            } else {
                              _excludedAllergens.remove(allergen.code);
                            }
                          });
                          setModalState(() {});
                          _loadCatalog();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    },
    loading: () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando alérgenos...')),
      );
    },
    error: (error, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar alérgenos: $error')),
      );
    },
  );
}
```

**Características**:
- **StatefulBuilder**: Permite actualizar el modal independientemente del widget padre
- **CheckboxListTile**: Permite selección múltiple de alérgenos
- **Botón Limpiar**: Resetea todos los alérgenos seleccionados
- **Contador en subtítulo**: Muestra cuántos alérgenos están seleccionados
- **Double setState**: 
  - `setState` para el widget padre (actualiza el botón en la UI principal)
  - `setModalState` para el modal (actualiza checkboxes)
- **Filtrado inverso**: Los alérgenos seleccionados **excluyen** productos (lógica de seguridad)

### 3. Filtro Vegano (Toggle)

```dart
AppFilterChip(
  label: 'Solo Vegano',
  selected: _isVegan == true,
  onTap: () {
    setState(() {
      _isVegan = _isVegan == true ? null : true;
    });
    _loadCatalog();
  },
  icon: Icons.eco,
),
```

**Características**:
- **Widget reutilizable**: `AppFilterChip` (definido en `core/widgets`)
- **Toggle behavior**: `null` → `true` → `null`
- **Indicador visual**: Icono `eco` verde cuando está activo
- **Estado tristate**: `null` = todos, `true` = solo veganos, `false` no se usa

### 4. Ordenación (Sort)

```dart
void _showSortOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: const Text('Ordenar por'),
          trailing: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const Divider(),
        _buildSortOption('Más reciente', 'createdAt', 'desc'),
        _buildSortOption('Más antiguo', 'createdAt', 'asc'),
        _buildSortOption('Precio: menor a mayor', 'price', 'asc'),
        _buildSortOption('Precio: mayor a menor', 'price', 'desc'),
        _buildSortOption('Nombre: A-Z', 'name', 'asc'),
        _buildSortOption('Nombre: Z-A', 'name', 'desc'),
        const SizedBox(height: 16),
      ],
    ),
  );
}

Widget _buildSortOption(String label, String sortBy, String sortOrder) {
  final isSelected = _sortBy == sortBy && _sortOrder == sortOrder;
  return ListTile(
    title: Text(label),
    trailing: isSelected ? const Icon(Icons.check) : null,
    selected: isSelected,
    onTap: () {
      setState(() {
        _sortBy = sortBy;
        _sortOrder = sortOrder;
      });
      Navigator.pop(context);
      _loadCatalog();
    },
  );
}
```

**Opciones disponibles**:
1. **Más reciente** (`createdAt`, `desc`) - Por defecto
2. **Más antiguo** (`createdAt`, `asc`)
3. **Precio: menor a mayor** (`price`, `asc`)
4. **Precio: mayor a menor** (`price`, `desc`)
5. **Nombre: A-Z** (`name`, `asc`)
6. **Nombre: Z-A** (`name`, `desc`)

### 5. Botón "Limpiar Filtros"

```dart
bool get _hasActiveFilters =>
    _selectedCategory != null ||
    _isVegan != null ||
    _excludedAllergens.isNotEmpty;

// En la UI
if (_hasActiveFilters)
  TextButton.icon(
    onPressed: _clearFilters,
    icon: const Icon(Icons.clear_all, size: 18),
    label: const Text('Limpiar filtros'),
    style: TextButton.styleFrom(
      foregroundColor: Colors.red,
    ),
  ),
```

```dart
void _clearFilters() {
  setState(() {
    _selectedCategory = null;
    _isVegan = null;
    _excludedAllergens.clear();
  });
  _loadCatalog();
}
```

**Características**:
- **Visible solo cuando hay filtros activos**: Mejor UX, no ocupa espacio innecesario
- **Resetea todos los filtros**: Excepto ordenación (se mantiene la preferencia)
- **Color rojo**: Indica acción destructiva
- **Recarga automática**: Muestra todos los productos

### UI de Filtros

```dart
Column(
  children: [
    // Primera fila: Categoría y Alérgenos
    Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCategorySelector(categoriesAsync),
              icon: const Icon(Icons.category),
              label: Text(
                _getCategoryLabel(categoriesAsync),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showAllergenSelector(allergensAsync),
              icon: const Icon(Icons.warning_amber),
              label: Text(
                _excludedAllergens.isEmpty 
                  ? 'Alérgenos' 
                  : 'Alérgenos (${_excludedAllergens.length})',
                overflow: TextOverflow.ellipsis,
              ),
              style: _excludedAllergens.isNotEmpty
                ? OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.orange, width: 2),
                    foregroundColor: Colors.orange,
                  )
                : null,
            ),
          ),
        ],
      ),
    ),
    
    // Segunda fila: Vegano y Limpiar
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          AppFilterChip(
            label: 'Solo Vegano',
            selected: _isVegan == true,
            onTap: () {
              setState(() {
                _isVegan = _isVegan == true ? null : true;
              });
              _loadCatalog();
            },
            icon: Icons.eco,
          ),
          const Spacer(),
          if (_hasActiveFilters)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Limpiar filtros'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
        ],
      ),
    ),
    
    const Divider(),
  ],
)
```

**Layout responsivo**:
- **Primera fila**: Dos botones expandibles (Categoría + Alérgenos)
- **Segunda fila**: Chip vegano + Spacer + Botón limpiar (condicional)
- **Divider**: Separa filtros del contenido
- **Padding consistente**: 16px horizontal para alineación

---

## 🎯 Sincronización de Filtros

### CatalogFilters Entity

```dart
class CatalogFilters {
  final String? categoryCode;
  final bool? isVegan;
  final List<String>? excludeAllergens;
  final String? sortBy;
  final String? sortOrder;
  final int? cursor;
  final int? limit;

  const CatalogFilters({
    this.categoryCode,
    this.isVegan,
    this.excludeAllergens,
    this.sortBy,
    this.sortOrder,
    this.cursor,
    this.limit,
  });

  CatalogFilters copyWith({
    String? categoryCode,
    bool? isVegan,
    List<String>? excludeAllergens,
    String? sortBy,
    String? sortOrder,
    int? cursor,
    int? limit,
  }) {
    return CatalogFilters(
      categoryCode: categoryCode ?? this.categoryCode,
      isVegan: isVegan ?? this.isVegan,
      excludeAllergens: excludeAllergens ?? this.excludeAllergens,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      cursor: cursor ?? this.cursor,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (categoryCode != null) params['categoryCode'] = categoryCode;
    if (isVegan != null) params['isVegan'] = isVegan;
    if (excludeAllergens != null && excludeAllergens!.isNotEmpty) {
      params['excludeAllergens'] = excludeAllergens;
    }
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (cursor != null) params['cursor'] = cursor;
    if (limit != null) params['limit'] = limit;
    
    return params;
  }
}
```

**Responsabilidades**:
- **Inmutabilidad**: Todos los campos son `final`
- **Valores opcionales**: Permite queries sin filtros
- **copyWith**: Facilita crear variaciones (ej: añadir cursor para paginación)
- **toQueryParams**: Convierte a Map para Dio (solo incluye valores no-null)

### Flujo de Sincronización

```
Usuario cambia filtro en UI
        ↓
    setState() actualiza variable local
        ↓
    _loadCatalog() construye CatalogFilters
        ↓
    catalogProvider.loadCatalog(filters)
        ↓
    Provider guarda filters en _currentFilters
        ↓
    GetCatalogUseCase.execute(filters)
        ↓
    ShopRepository.getCatalog(filters)
        ↓
    ShopApiClient hace GET /products con filters.toQueryParams()
        ↓
    Backend aplica filtros en SQL/TypeORM
        ↓
    Respuesta → PaginatedCatalog → CatalogState → UI
```

## 🎨 Widgets del Catálogo

### 1. ProductCard

Widget reutilizable que muestra un producto o menú en el grid del catálogo.

#### Código Completo

```dart
import 'package:flutter/material.dart';
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
            // Imagen con aspect ratio fijo
            AspectRatio(
              aspectRatio: 16 / 9,
              child: item.images.isNotEmpty
                  ? Image.network(
                      item.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
            
            // Contenido expandible
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badges: Menú + Vegano
                    Row(
                      children: [
                        if (item.isMenu)
                          Chip(
                            label: const Text('Menú', style: TextStyle(fontSize: 10)),
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
                    
                    // Nombre del producto
                    Text(
                      item.nameEs,
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
                        item.descriptionEs,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Precio y botón añadir
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
```

#### Características Destacadas

- **AspectRatio 16:9**: Garantiza imágenes uniformes en el grid
- **Image.network con errorBuilder**: Maneja fallos de carga con placeholder
- **Badge "Menú"**: Distingue visualmente menús de productos
- **Icono vegano**: Hoja verde para identificación rápida
- **Botón añadir opcional**: `onAddToCart` puede ser null si no se necesita
- **Overflow ellipsis**: Texto truncado con "..." si es muy largo
- **InkWell**: Efecto ripple al tocar
- **Material Design 3**: Usa `colorScheme` para theming consistente

#### Uso en ShopPage

```dart
return ProductCard(
  item: item,
  onTap: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductDetailModal(item: item),
    );
  },
  onAddToCart: () {
    ref.read(cartProvider.notifier).addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nameEs} añadido al carrito'),
        duration: const Duration(seconds: 1),
      ),
    );
  },
);
```

---

### 2. ProductDetailModal

Modal detallado con carrusel de imágenes, información completa y botón para añadir al carrito.

#### Características Principales

- **DraggableScrollableSheet**: Modal arrastrable hacia arriba/abajo
- **PageView con autoplay**: Carrusel de imágenes con cambio automático cada 5 segundos
- **Indicadores de página**: Dots que muestran la imagen actual
- **Información completa**: Nombre, categoría, precio, descripción, alérgenos
- **Scroll infinito**: Contenido desplazable si es muy largo

#### Código (Extracto Principal)

```dart
class _ProductDetailModalState extends State<ProductDetailModal> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (widget.item.images.length > 1) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (_pageController.hasClients) {
          final nextPage = (_currentImageIndex + 1) % widget.item.images.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle para arrastrar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Carrusel de imágenes
                      SizedBox(
                        height: 300,
                        child: Stack(
                          children: [
                            PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() => _currentImageIndex = index);
                              },
                              itemCount: widget.item.images.length,
                              itemBuilder: (context, index) {
                                return Image.network(
                                  widget.item.images[index],
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                            // Indicadores
                            if (widget.item.images.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    widget.item.images.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == index
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // Información del producto
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges
                            Row(
                              children: [
                                if (widget.item.isMenu)
                                  Chip(label: const Text('Menú')),
                                if (widget.item.isVegan)
                                  Chip(label: const Text('Vegano')),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Nombre
                            Text(
                              widget.item.nameEs,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            
                            // Categoría
                            Text(
                              widget.item.category.nameEs.toUpperCase(),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            
                            // Precio
                            Text(
                              '${widget.item.price.toStringAsFixed(2)} ${widget.item.currency}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            
                            // Descripción
                            Text(widget.item.descriptionEs),
                            
                            // Alérgenos si los hay
                            if (widget.item.allergens.isNotEmpty) ...[
                              const Divider(),
                              Text('Alérgenos:', 
                                style: Theme.of(context).textTheme.titleMedium),
                              // Lista de alérgenos con chips
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

#### Detalles Técnicos

**Timer.periodic para autoplay**:
```dart
_autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
  if (_pageController.hasClients) {
    final nextPage = (_currentImageIndex + 1) % widget.item.images.length;
    _pageController.animateToPage(nextPage, ...);
  }
});
```
- Cambia imagen cada 5 segundos
- Usa módulo `%` para volver al inicio
- Verifica `hasClients` antes de animar (evita errores si el widget ya no existe)

**Gestión de memoria**:
```dart
@override
void dispose() {
  _autoPlayTimer?.cancel();  // Cancelar timer
  _pageController.dispose();  // Liberar controller
  super.dispose();
}
```

---

### 3. AppFilterChip

Widget reutilizable para chips de filtro con estilo consistente.

#### Código

```dart
import 'package:flutter/material.dart';

/// Chip de filtro reutilizable con estilo consistente
class AppFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon, 
              size: 16,
              color: selected && icon == Icons.eco
                  ? Colors.green.shade800
                  : null,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: selected && icon == Icons.eco
                  ? Colors.green.shade900
                  : null,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: icon == Icons.eco && selected
          ? Colors.green.shade200  // Verde claro para vegano
          : Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: icon == Icons.eco && selected
          ? Colors.green.shade800
          : Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(
        color: selected
            ? (icon == Icons.eco ? Colors.green : Theme.of(context).colorScheme.primary)
            : Theme.of(context).colorScheme.outline,
      ),
    );
  }
}
```

#### Características

- **Icono opcional**: Se puede usar con o sin icono
- **Estilos condicionales**: Verde especial para filtro vegano (`Icons.eco`)
- **Material Design 3**: Respeta el tema de la app
- **Reutilizable**: Usado en Shop y potencialmente otros módulos

---

## 🔄 Providers y Estado (Riverpod)

### Arquitectura de Providers

```dart
// Providers de dependencias
shopApiClientProvider
    ↓
shopRepositoryProvider
    ↓
getCatalogUseCaseProvider
getAllergensUseCaseProvider
getCategoriesUseCaseProvider
    ↓
catalogProvider (Notifier)
allergensProvider (FutureProvider)
categoriesProvider (FutureProvider)
```

### 1. Providers de Infraestructura

```dart
/// Provider del API client
final shopApiClientProvider = Provider<ShopApiClient>((ref) {
  return ShopApiClient();
});

/// Provider del repositorio
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final apiClient = ref.watch(shopApiClientProvider);
  return ShopRepositoryImpl(apiClient: apiClient);
});

/// Provider de casos de uso
final getCatalogUseCaseProvider = Provider<GetCatalogUseCase>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return GetCatalogUseCase(repository);
});

final getAllergensUseCaseProvider = Provider<GetAllergensUseCase>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return GetAllergensUseCase(repository);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return GetCategoriesUseCase(repository);
});
```

**Patrón de dependencias**:
- Cada provider depende del anterior
- `ref.watch` establece la relación de dependencia
- Riverpod maneja automáticamente el ciclo de vida
- Si un provider se invalida, los dependientes se reconstruyen

---

### 2. CatalogNotifier (Estado del Catálogo)

```dart
/// Notificador del catálogo con paginación
class CatalogNotifier extends Notifier<CatalogState> {
  CatalogFilters _currentFilters = const CatalogFilters(limit: 20);
  bool _isLoadingMore = false;

  @override
  CatalogState build() => CatalogState.initial();

  GetCatalogUseCase get _getCatalogUseCase => ref.read(getCatalogUseCaseProvider);

  /// Carga inicial del catálogo
  Future<void> loadCatalog(CatalogFilters filters) async {
    _currentFilters = filters.copyWith(limit: 20, cursor: null);
    state = state.loading();

    try {
      final result = await _getCatalogUseCase.execute(_currentFilters);
      state = state.withData(
        items: result.items,
        hasMore: result.hasMore,
        nextCursor: result.nextCursor?.toString(),
      );
    } catch (e) {
      state = state.withError(e.toString());
    }
  }

  /// Carga más items (infinite scroll)
  Future<void> loadMore() async {
    // Evitar múltiples llamadas simultáneas
    if (_isLoadingMore || !state.hasMore || state.isLoading || state.nextCursor == null) {
      return;
    }

    _isLoadingMore = true;
    
    // NO cambiar isLoading a true, mantener items actuales visibles
    final currentItems = state.items;

    try {
      final filters = _currentFilters.copyWith(
        cursor: int.tryParse(state.nextCursor ?? ''),
      );
      final result = await _getCatalogUseCase.execute(filters);

      // Filtrar duplicados por ID
      final existingIds = currentItems.map((item) => item.id).toSet();
      final newItems = result.items.where((item) => !existingIds.contains(item.id)).toList();

      state = state.withData(
        items: [...currentItems, ...newItems],
        hasMore: result.hasMore,
        nextCursor: result.nextCursor?.toString(),
      );
    } catch (e) {
      state = state.withError(e.toString());
    } finally {
      _isLoadingMore = false;
    }
  }
}

/// Provider del catálogo
final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(() {
  return CatalogNotifier();
});
```

#### Características del Notifier

**loadCatalog** (Carga inicial):
- Resetea el cursor a `null`
- Marca el estado como `loading` (muestra spinner)
- Ejecuta el caso de uso
- Actualiza el estado con los nuevos items

**loadMore** (Paginación):
- Verifica condiciones antes de cargar:
  - No hay otra carga en proceso (`_isLoadingMore`)
  - Hay más items disponibles (`state.hasMore`)
  - No está cargando ya (`!state.isLoading`)
  - Existe un cursor (`state.nextCursor != null`)
- **NO marca como loading**: Mantiene los items visibles mientras carga más
- Usa `_isLoadingMore` para evitar llamadas duplicadas
- Filtra duplicados por ID (seguridad ante posibles overlaps)
- Concatena items existentes con nuevos items
- Usa `finally` para resetear `_isLoadingMore` siempre

**¿Por qué `_isLoadingMore` separado?**
- `state.isLoading` mostraría spinner y ocultaría items actuales
- `_isLoadingMore` es una flag interna solo para control de flujo
- Permite mostrar un pequeño loading al final del grid sin afectar lo visible

---

### 3. FutureProviders (Alérgenos y Categorías)

```dart
/// Provider de alérgenos
final allergensProvider = FutureProvider<List<Allergen>>((ref) async {
  final useCase = ref.watch(getAllergensUseCaseProvider);
  return await useCase.execute();
});

/// Provider de categorías
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return await useCase.execute();
});
```

**Uso en UI**:
```dart
final allergensAsync = ref.watch(allergensProvider);

allergensAsync.when(
  data: (allergens) => _showAllergenSelector(allergens),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

**Ventajas de FutureProvider**:
- Cachea el resultado automáticamente
- Maneja estados loading/error/data
- Se recarga automáticamente si hay cambios en dependencias
- Perfecto para datos que no cambian frecuentemente (categorías, alérgenos)

---

### 4. CatalogState (Entity)

```dart
/// Estado del catálogo con items, paginación y loading
class CatalogState {
  final List<CatalogItem> items;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const CatalogState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });

  CatalogState copyWith({
    List<CatalogItem>? items,
    bool? isLoading,
    bool? hasMore,
    String? nextCursor,
    String? error,
  }) {
    return CatalogState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: error ?? this.error,
    );
  }

  /// Estado inicial vacío
  factory CatalogState.initial() {
    return const CatalogState();
  }

  /// Estado de carga
  CatalogState loading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Estado con datos
  CatalogState withData({
    required List<CatalogItem> items,
    required bool hasMore,
    String? nextCursor,
  }) {
    return copyWith(
      items: items,
      isLoading: false,
      hasMore: hasMore,
      nextCursor: nextCursor,
      error: null,
    );
  }

  /// Estado con error
  CatalogState withError(String error) {
    return copyWith(
      isLoading: false,
      error: error,
    );
  }
}
```

**Métodos helper**:
- `initial()`: Estado vacío al iniciar
- `loading()`: Marca como cargando, limpia error
- `withData()`: Actualiza items y paginación, limpia loading y error
- `withError()`: Guarda error, limpia loading

---

## 💾 Capa de Datos

### 1. ShopRepository (Interface)

```dart
import '../entities/catalog_filters.dart';
import '../entities/paginated_catalog.dart';
import '../entities/allergen.dart';
import '../entities/category.dart';

/// Repositorio del catálogo de productos y menús
abstract class ShopRepository {
  /// Obtiene el catálogo con filtros y paginación
  Future<PaginatedCatalog> getCatalog(CatalogFilters filters);
  
  /// Obtiene todos los alérgenos disponibles
  Future<List<Allergen>> getAllergens();
  
  /// Obtiene todas las categorías disponibles
  Future<List<Category>> getCategories();
}
```

**Patrón Repository**:
- Define **contratos** sin implementación
- Permite testing con mocks fácilmente
- Separa lógica de negocio de infraestructura
- Sigue el **Dependency Inversion Principle** (SOLID)

---

### 2. ShopRepositoryImpl

```dart
import '../../domain/entities/catalog_filters.dart';
import '../../domain/entities/paginated_catalog.dart';
import '../../domain/entities/allergen.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_api_client.dart';

/// Implementación del repositorio de Shop
class ShopRepositoryImpl implements ShopRepository {
  final ShopApiClient _apiClient;

  ShopRepositoryImpl({required ShopApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PaginatedCatalog> getCatalog(CatalogFilters filters) async {
    return await _apiClient.getCatalog(filters);
  }

  @override
  Future<List<Allergen>> getAllergens() async {
    return await _apiClient.getAllergens();
  }

  @override
  Future<List<Category>> getCategories() async {
    return await _apiClient.getCategories();
  }
}
```

**Responsabilidad**:
- Implementa la interface `ShopRepository`
- Delega las llamadas al `ShopApiClient`
- Aquí se podría añadir lógica de cacheo local
- Manejo de errores específico del datasource

---

### 3. ShopApiClient (Datasource)

```dart
import 'package:dio/dio.dart';
import '../../domain/entities/catalog_filters.dart';
import '../../domain/entities/paginated_catalog.dart';
import '../../domain/entities/allergen.dart';
import '../../domain/entities/category.dart';
import '../../../../core/utils/app_services.dart';

/// Cliente API para el módulo Shop
class ShopApiClient {
  final Dio _dio;

  ShopApiClient({Dio? dio}) : _dio = dio ?? AppServices.dio;

  /// Obtiene el catálogo con filtros
  Future<PaginatedCatalog> getCatalog(CatalogFilters filters) async {
    try {
      final queryParams = filters.toQueryParams();
      
      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      return PaginatedCatalog.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtiene todos los alérgenos disponibles
  Future<List<Allergen>> getAllergens() async {
    try {
      final response = await _dio.get('/products/allergens');
      
      return (response.data as List)
          .map((json) => Allergen.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Obtiene todas las categorías disponibles
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/products/categories');
      
      return (response.data as List)
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      return Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
    } else {
      return Exception('Error de red: ${e.message}');
    }
  }
}
```

#### Detalles de Implementación

**Uso de Dio**:
- Usa instancia compartida de `AppServices.dio` (configurada globalmente)
- Convierte `CatalogFilters` a `queryParameters` automáticamente
- Maneja errores con `try-catch` de `DioException`

**Endpoints**:
- `GET /products` → Catálogo con filtros
- `GET /products/allergens` → Lista de alérgenos
- `GET /products/categories` → Lista de categorías

**Manejo de errores**:
```dart
Exception _handleDioError(DioException e) {
  if (e.response != null) {
    // Error del servidor (4xx, 5xx)
    return Exception('Error ${e.response!.statusCode}: ${e.response!.data}');
  } else {
    // Error de red (sin conexión, timeout)
    return Exception('Error de red: ${e.message}');
  }
}
```

---

## 🔗 Integración con Backend

### Arquitectura Backend (NestJS)

```
ProductsController (API)
        ↓
QueryCatalogUseCase
        ↓
ProductRepository + RescueMenuRepository
        ↓
TypeORM QueryBuilder
        ↓
PostgreSQL Database
```

### 1. Endpoint Principal

```typescript
@Get()
@ApiOperation({
  summary: 'Catálogo unificado de productos y menús',
  description: 'Devuelve un catálogo paginado con productos y menús...',
})
async getAll(
  @Query() filters: QueryCatalogRequestDto,
): Promise<PaginatedResponseDto<CatalogItemResponseDto>> {
  const result = await this.queryCatalogUseCase.execute(filters);
  return this.catalogAssembler.toPaginatedResponse(result);
}
```

**URL**: `GET /products`

**Query Parameters**:
- `categoryCode`: Código de categoría (opcional)
- `isVegan`: Boolean, true para solo veganos (opcional)
- `excludeAllergens`: Array de códigos de alérgenos a excluir (opcional)
- `sortBy`: Campo de ordenación: `price`, `name`, `createdAt` (opcional)
- `sortOrder`: Dirección: `asc`, `desc` (opcional)
- `cursor`: ID del último item de la página anterior (opcional)
- `limit`: Número de items por página (default: 10)

---

### 2. QueryCatalogUseCase

```typescript
@Injectable()
export class QueryCatalogUseCase {
  constructor(
    @Inject(IProductRepository)
    private readonly productRepository: IProductRepository,
    @Inject(IRescueMenuRepository)
    private readonly rescueMenuRepository: IRescueMenuRepository,
  ) {}

  async execute(filters: CatalogFilters): Promise<PaginatedResult<CatalogItem>> {
    const MENU_CATEGORY_CODE = 'MENUS';
    const isMenuFilter = filters.categoryCode?.toUpperCase() === MENU_CATEGORY_CODE;
    
    let productsResult: PaginatedResult<ProductWithDetails>;
    let menusResult: PaginatedResult<MenuWithDetails>;
    
    if (isMenuFilter) {
      // Solo menús
      menusResult = await this.rescueMenuRepository.findWithFilters(filters);
      productsResult = { items: [], total: 0, nextCursor: null };
    } else if (filters.categoryCode) {
      // Solo productos (otra categoría específica)
      productsResult = await this.productRepository.findWithFilters(filters);
      menusResult = { items: [], total: 0, nextCursor: null };
    } else {
      // Sin filtro de categoría: consultar ambos
      [productsResult, menusResult] = await Promise.all([
        this.productRepository.findWithFilters(filters),
        this.rescueMenuRepository.findWithFilters(filters),
      ]);
    }

    // Convertir a CatalogItem
    const productItems = this.convertProductsToCatalogItems(productsResult.items);
    const menuItems = this.convertMenusToCatalogItems(menusResult.items);

    // Combinar items
    const allItems = [...productItems, ...menuItems];

    // Ordenar items combinados
    const sortedItems = this.sortCombinedItems(allItems, filters);

    // Aplicar paginación
    const limit = filters.limit || 10;
    const paginatedItems = this.applyPagination(sortedItems, filters.cursor, limit);

    // Calcular totales y cursor
    const total = productsResult.total + menusResult.total;
    const hasMore = paginatedItems.length > limit;
    const items = hasMore ? paginatedItems.slice(0, limit) : paginatedItems;
    const nextCursor = hasMore ? items[items.length - 1].id : null;

    return { items, total, nextCursor };
  }
}
```

#### Lógica de Combinación

**Estrategia de queries**:
1. Si `categoryCode === 'MENUS'` → Solo query a `rescue_menu`
2. Si `categoryCode` es otra → Solo query a `product`
3. Si no hay `categoryCode` → Query ambas tablas en paralelo (`Promise.all`)

**¿Por qué esta estrategia?**
- **Optimización**: No consulta tablas innecesarias
- **Rendimiento**: Queries paralelas cuando es necesario
- **Flexibilidad**: Menús pueden tener su propia categoría lógica

**Ordenación**:
```typescript
private sortCombinedItems(items: CatalogItem[], filters: CatalogFilters): CatalogItem[] {
  const sortBy = filters.sortBy || 'createdAt';
  const sortOrder = filters.sortOrder || 'desc';

  return items.sort((a, b) => {
    let comparison = 0;

    switch (sortBy) {
      case 'price':
        comparison = a.price - b.price;
        break;
      case 'name':
        const nameA = a.nameEs || a.nameEn || '';
        const nameB = b.nameEs || b.nameEn || '';
        comparison = nameA.localeCompare(nameB);
        break;
      case 'createdAt':
        comparison = a.createdAt.getTime() - b.createdAt.getTime();
        break;
    }

    return sortOrder === 'desc' ? -comparison : comparison;
  });
}
```

---

### 3. Filtros en TypeORM

#### Filtro de Categoría

```typescript
if (filters.categoryCode) {
  query.andWhere('category.code = :categoryCode', { 
    categoryCode: filters.categoryCode 
  });
}
```

#### Filtro Vegano

```typescript
if (filters.isVegan !== undefined) {
  const veganValue = filters.isVegan ? 1 : 0;
  query.andWhere('product.is_vegan = :isVegan', { isVegan: veganValue });
}
```

#### Filtro de Alérgenos (INVERSO)

```typescript
if (filters.excludeAllergens && filters.excludeAllergens.length > 0) {
  const allergensList = Array.isArray(filters.excludeAllergens) 
    ? filters.excludeAllergens 
    : [filters.excludeAllergens];
  
  query.andWhere((qb) => {
    const subQuery = qb
      .subQuery()
      .select('pa.productId')
      .from('product_allergen', 'pa')
      .where('pa.allergenCode IN (:...allergens)', { allergens: allergensList })
      .andWhere('pa.contains = true')
      .getQuery();
    return `product.id NOT IN ${subQuery}`;
  });
}
```

**Explicación del filtro de alérgenos**:
- **Subquery**: Selecciona IDs de productos que **contienen** los alérgenos
- **NOT IN**: Excluye esos productos del resultado
- **Lógica inversa**: Si seleccionas "Gluten", NO ves productos con gluten
- **Seguridad**: Garantiza que el usuario no vea productos peligrosos para él

---

## 💡 Decisiones de Diseño

### 1. ¿Por qué Catálogo Unificado?

**Decisión**: Combinar productos y menús en un solo listado

**Alternativas consideradas**:
- ❌ Tabs separados (Productos / Menús)
- ❌ Páginas diferentes
- ✅ **Grid unificado con badge "Menú"**

**Justificación**:
- **UX simplificada**: El usuario ve todo de un vistazo
- **Descubrimiento**: Los menús no quedan ocultos en otra tab
- **Filtrado coherente**: Mismos filtros aplican a ambos
- **Scroll infinito unificado**: Experiencia fluida sin saltos

---

### 2. ¿Por qué Cursor-Based Pagination?

**Decisión**: Usar IDs como cursor en lugar de offset/limit

**Alternativas consideradas**:
- ❌ **Offset/Limit** (`?page=2&limit=20`)
- ✅ **Cursor** (`?cursor=123&limit=20`)

**Ventajas del cursor**:
- **Consistencia**: No hay duplicados si se añaden items mientras scrolleas
- **Performance**: No re-calcula offsets grandes (eficiente en tablas grandes)
- **Realtime-friendly**: Funciona bien si los datos cambian frecuentemente
- **Escalabilidad**: Mejor rendimiento en millones de registros

**Desventajas**:
- No se puede saltar a página específica (ej: "ir a página 5")
- Pero para infinite scroll, esto no importa

---

### 3. ¿Por qué Filtrado de Alérgenos Inverso?

**Decisión**: Los alérgenos seleccionados **excluyen** productos

**Alternativa**:
- ❌ Mostrar solo productos que **contengan** esos alérgenos

**Justificación**:
- **Seguridad**: Si eres alérgico al gluten, NO quieres ver productos con gluten
- **UX médica**: Aplicaciones de salud usan este patrón
- **Confianza**: El usuario siente que la app protege su salud
- **Claridad**: Mensaje claro: "Selecciona las alergias para tu seguridad"

---

### 4. ¿Por qué Estado Local para Filtros?

**Decisión**: Guardar filtros en estado local (`_selectedCategory`, etc.) en lugar de provider global

**Alternativas**:
- ❌ Provider global de filtros compartido
- ✅ **Estado local en _ShopPageState**

**Justificación**:
- **Scope limitado**: Los filtros solo importan en ShopPage
- **Performance**: No propaga rebuilds a otros widgets
- **Reset fácil**: Al salir de la página, filtros se resetean automáticamente
- **Simplicidad**: Menos código, menos complejidad

---

### 5. ¿Por qué Riverpod Notifier?

**Decisión**: Usar `Notifier<CatalogState>` en lugar de `StateNotifier`

**Alternativas**:
- ❌ `StateNotifier` (deprecated en Riverpod 2.0+)
- ❌ `ChangeNotifier` (patrón antiguo de Flutter)
- ✅ **Notifier** (recomendación oficial Riverpod 3.0)

**Ventajas**:
- **Moderno**: API más limpia y type-safe
- **Sintaxis simplificada**: `ref.read` en lugar de `ref.container.read`
- **Mejor testing**: Más fácil de mockear
- **Futuro-proof**: No quedará deprecated

---

### 6. ¿Por qué FutureProvider para Alérgenos/Categorías?

**Decisión**: Usar `FutureProvider` para datos estáticos

**Alternativas**:
- ❌ Cargar en cada render de ShopPage
- ❌ Provider con Notifier para datos que no cambian
- ✅ **FutureProvider con caché automático**

**Justificación**:
- **Caché**: Solo carga una vez, reutiliza el resultado
- **Simplicidad**: No necesita notifier para datos read-only
- **Eficiencia**: No re-fetches innecesarios
- **Patrón estándar**: Recomendación de Riverpod para datos asincrónicos estáticos

---

### 7. ¿Por qué DraggableScrollableSheet?

**Decisión**: Modales con sheet arrastrable en lugar de Dialog

**Alternativas**:
- ❌ `AlertDialog` (modal centrado pequeño)
- ❌ `BottomSheet` estático
- ✅ **DraggableScrollableSheet**

**Ventajas**:
- **UX móvil nativa**: Gesto de arrastrar es intuitivo en móviles
- **Flexibilidad**: Usuario controla tamaño del modal
- **Contenido largo**: Perfecto para listas de categorías/alérgenos
- **Modern design**: Patrón usado en apps populares (Instagram, Twitter)

---

## 📊 Resumen del Flujo Completo

```
1. Usuario entra a ShopPage
        ↓
2. initState() → addPostFrameCallback → _loadCatalog()
        ↓
3. Construye CatalogFilters con valores por defecto
        ↓
4. catalogProvider.loadCatalog(filters)
        ↓
5. GetCatalogUseCase.execute(filters)
        ↓
6. ShopRepository.getCatalog(filters)
        ↓
7. ShopApiClient GET /products?categoryCode=...&isVegan=...
        ↓
8. Backend QueryCatalogUseCase
        ↓
9. ProductRepository.findWithFilters() + RescueMenuRepository.findWithFilters()
        ↓
10. TypeORM aplica WHERE, JOIN, ORDER BY
        ↓
11. PostgreSQL ejecuta query
        ↓
12. Respuesta JSON → PaginatedCatalog entity
        ↓
13. CatalogState.withData() actualiza estado
        ↓
14. UI re-renderiza con GridView de ProductCards
        ↓
15. Usuario scrollea cerca del final
        ↓
16. _onScroll() detecta → catalogProvider.loadMore()
        ↓
17. Usa nextCursor para cargar página siguiente
        ↓
18. Concatena nuevos items a lista existente
        ↓
19. UI muestra items adicionales sin perder scroll position
```

---

## 🎯 Conclusión

El **módulo Shop** es el corazón de EcoBocado, demostrando:

✅ **Clean Architecture** completa en Flutter  
✅ **State management** avanzado con Riverpod 3.0  
✅ **Paginación infinita** eficiente con cursor-based pagination  
✅ **Sistema de filtros** complejo con lógica de seguridad (alérgenos inversos)  
✅ **Integración backend** full-stack con NestJS + TypeORM  
✅ **UX nativa** con DraggableScrollableSheet y gestos intuitivos  
✅ **Optimización** de queries con combinación inteligente de tablas  
✅ **Escalabilidad** preparada para millones de productos  