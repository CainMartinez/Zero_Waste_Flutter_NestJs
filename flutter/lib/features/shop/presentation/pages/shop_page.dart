import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/catalog_filters.dart';
import '../../domain/entities/catalog_state.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/allergen.dart';
import '../providers/catalog_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/product_detail_modal.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../../core/widgets/app_filter_chip.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  final ScrollController _scrollController = ScrollController();
  
  // Filtros
  String? _selectedCategory;
  bool? _isVegan;
  List<String> _excludedAllergens = [];
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCatalog();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Cerca del final, cargar más
      ref.read(catalogProvider.notifier).loadMore();
    }
  }

  void _loadCatalog() {
    final filters = CatalogFilters(
      categoryCode: _selectedCategory,
      isVegan: _isVegan,
      excludeAllergens: _excludedAllergens.isEmpty ? null : _excludedAllergens,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      limit: 20,
    );
    ref.read(catalogProvider.notifier).loadCatalog(filters);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _isVegan = null;
      _excludedAllergens.clear();
    });
    _loadCatalog();
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _isVegan != null ||
      _excludedAllergens.isNotEmpty;



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
                      ListTile(
                        title: const Text('Todas'),
                        trailing: _selectedCategory == null ? const Icon(Icons.check) : null,
                        selected: _selectedCategory == null,
                        onTap: () {
                          setState(() => _selectedCategory = null);
                          Navigator.pop(context);
                          _loadCatalog();
                        },
                      ),
                      ...categories.map((category) => ListTile(
                            title: Text(category.nameEs),
                            trailing: _selectedCategory == category.code ? const Icon(Icons.check) : null,
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

  String _getCategoryLabel(AsyncValue<List<Category>> categoriesAsync) {
    if (_selectedCategory == null) return 'Todas las Categorías';
    
    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.code == _selectedCategory,
          orElse: () => Category(id: 0, code: '', nameEs: 'Todas', nameEn: ''),
        );
        return category.nameEs;
      },
      loading: () => 'Cargando...',
      error: (_, __) => 'Error',
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalogState = ref.watch(catalogProvider);
    final cartItemCount = ref.watch(cartItemCountProvider);
    
    // Precargar categorías y alérgenos
    final categoriesAsync = ref.watch(categoriesProvider);
    final allergensAsync = ref.watch(allergensProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Disfruta la comida Zero Waste'),
        actions: [
          // Botón de ordenar
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          // Carrito con badge
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
      body: Column(
        children: [
          // Filtros en fila
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Selector de categoría
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
                // Selector de alérgenos
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
          
          // Filtro vegano y botón limpiar
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
          
          // Lista de productos
          Expanded(
            child: _buildProductList(catalogState),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(CatalogState catalogState) {
    if (catalogState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${catalogState.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCatalog,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (catalogState.items.isEmpty && !catalogState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 48),
            SizedBox(height: 16),
            Text('No se encontraron productos'),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: catalogState.items.length + (catalogState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= catalogState.items.length) {
          // Loading indicator al final
          return const Center(child: CircularProgressIndicator());
        }

        final item = catalogState.items[index];
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
      },
    );
  }
}
