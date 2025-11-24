import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eco_bocado/features/admin/data/datasources/product_admin_remote_datasource.dart';
import 'package:eco_bocado/features/admin/data/repositories/product_admin_repository_impl.dart';
import 'package:eco_bocado/features/admin/domain/entities/product_admin.dart';
import 'package:eco_bocado/features/admin/domain/repositories/product_admin_repository.dart';

// Provider del datasource
final productAdminRemoteDataSourceProvider = Provider<ProductAdminRemoteDataSource>((ref) {
  return ProductAdminRemoteDataSource();
});

// Provider del repositorio
final productAdminRepositoryProvider = Provider<ProductAdminRepository>((ref) {
  final dataSource = ref.watch(productAdminRemoteDataSourceProvider);
  return ProductAdminRepositoryImpl(dataSource);
});

// State para la lista de productos
class ProductAdminState {
  final List<ProductAdmin> products;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> allergens;
  final bool isLoading;
  final bool isLoadingCategories;
  final bool isLoadingAllergens;
  final String? errorMessage;

  ProductAdminState({
    this.products = const [],
    this.categories = const [],
    this.allergens = const [],
    this.isLoading = false,
    this.isLoadingCategories = false,
    this.isLoadingAllergens = false,
    this.errorMessage,
  });

  ProductAdminState copyWith({
    List<ProductAdmin>? products,
    List<Map<String, dynamic>>? categories,
    List<Map<String, dynamic>>? allergens,
    bool? isLoading,
    bool? isLoadingCategories,
    bool? isLoadingAllergens,
    String? errorMessage,
  }) {
    return ProductAdminState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      allergens: allergens ?? this.allergens,
      isLoading: isLoading ?? this.isLoading,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isLoadingAllergens: isLoadingAllergens ?? this.isLoadingAllergens,
      errorMessage: errorMessage,
    );
  }
}

// Notifier para gestionar el estado de productos
class ProductAdminNotifier extends Notifier<ProductAdminState> {
  late ProductAdminRepository _repository;

  @override
  ProductAdminState build() {
    _repository = ref.watch(productAdminRepositoryProvider);
    return ProductAdminState();
  }

  // Cargar todos los productos
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final products = await _repository.getAllProducts();
      state = state.copyWith(
        products: products,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Cargar categorías
  Future<void> loadCategories() async {
    if (state.categories.isNotEmpty) return; // Ya están cargadas
    
    state = state.copyWith(isLoadingCategories: true);
    
    try {
      final categories = await _repository.getCategories();
      state = state.copyWith(
        categories: categories,
        isLoadingCategories: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCategories: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Cargar alérgenos
  Future<void> loadAllergens() async {
    if (state.allergens.isNotEmpty) return; // Ya están cargados
    
    state = state.copyWith(isLoadingAllergens: true);
    
    try {
      final allergens = await _repository.getAllergens();
      state = state.copyWith(
        allergens: allergens,
        isLoadingAllergens: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingAllergens: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Subir imagen para un producto
  Future<String?> uploadProductImage(int productId, dynamic imageData) async {
    try {
      final imagePath = await _repository.uploadProductImage(productId, imageData);
      return imagePath;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  // Eliminar imagen
  Future<bool> deleteProductImage(int imageId) async {
    try {
      await _repository.deleteProductImage(imageId);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Actualizar alérgenos de un producto
  Future<bool> updateProductAllergens(int productId, List<Map<String, dynamic>> allergens) async {
    try {
      await _repository.updateProductAllergens(productId, allergens);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Crear producto
  Future<ProductAdmin?> createProduct({
    required String nameEs,
    required String nameEn,
    required String descriptionEs,
    required String descriptionEn,
    required double price,
    String currency = 'EUR',
    bool isVegan = false,
    required int categoryId,
  }) async {
    try {
      final newProduct = await _repository.createProduct(
        nameEs: nameEs,
        nameEn: nameEn,
        descriptionEs: descriptionEs,
        descriptionEn: descriptionEn,
        price: price,
        currency: currency,
        isVegan: isVegan,
        categoryId: categoryId,
      );
      
      // Añadir al principio de la lista
      state = state.copyWith(
        products: [newProduct, ...state.products],
      );
      
      return newProduct;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  // Actualizar producto
  Future<bool> updateProduct({
    required int id,
    String? nameEs,
    String? nameEn,
    String? descriptionEs,
    String? descriptionEn,
    double? price,
    String? currency,
    bool? isVegan,
    int? categoryId,
  }) async {
    try {
      final updatedProduct = await _repository.updateProduct(
        id: id,
        nameEs: nameEs,
        nameEn: nameEn,
        descriptionEs: descriptionEs,
        descriptionEn: descriptionEn,
        price: price,
        currency: currency,
        isVegan: isVegan,
        categoryId: categoryId,
      );
      
      // Actualizar en la lista
      final updatedList = state.products.map((p) {
        return p.id == id ? updatedProduct : p;
      }).toList();
      
      state = state.copyWith(products: updatedList);
      
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Eliminar producto (soft delete)
  Future<bool> deleteProduct(int id) async {
    try {
      await _repository.deleteProduct(id);
      
      // Actualizar isActive en la lista local
      final updatedList = state.products.map((p) {
        return p.id == id ? p.copyWith(isActive: false) : p;
      }).toList();
      
      state = state.copyWith(products: updatedList);
      
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Reactivar producto
  Future<bool> reactivateProduct(int id) async {
    try {
      final reactivatedProduct = await _repository.reactivateProduct(id);
      
      // Actualizar en la lista
      final updatedList = state.products.map((p) {
        return p.id == id ? reactivatedProduct : p;
      }).toList();
      
      state = state.copyWith(products: updatedList);
      
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  // Limpiar mensaje de error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Provider del notifier
final productAdminProvider = NotifierProvider<ProductAdminNotifier, ProductAdminState>(() {
  return ProductAdminNotifier();
});
