import '../entities/catalog_filters.dart';
import '../entities/paginated_catalog.dart';
import '../repositories/shop_repository.dart';

/// Caso de uso para obtener el catálogo de productos/menús
class GetCatalogUseCase {
  final ShopRepository _repository;

  GetCatalogUseCase(this._repository);

  Future<PaginatedCatalog> execute(CatalogFilters filters) {
    return _repository.getCatalog(filters);
  }
}
