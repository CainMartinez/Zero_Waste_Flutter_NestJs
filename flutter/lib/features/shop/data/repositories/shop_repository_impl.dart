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
