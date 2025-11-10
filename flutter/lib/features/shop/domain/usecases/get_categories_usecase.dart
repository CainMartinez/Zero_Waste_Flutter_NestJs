import '../entities/category.dart';
import '../repositories/shop_repository.dart';

/// Caso de uso para obtener la lista de categorías
class GetCategoriesUseCase {
  final ShopRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<List<Category>> execute() {
    return _repository.getCategories();
  }
}
