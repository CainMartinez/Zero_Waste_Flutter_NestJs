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