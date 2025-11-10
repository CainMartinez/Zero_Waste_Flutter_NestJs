import '../entities/allergen.dart';
import '../repositories/shop_repository.dart';

/// Caso de uso para obtener la lista de alérgenos
class GetAllergensUseCase {
  final ShopRepository _repository;

  GetAllergensUseCase(this._repository);

  Future<List<Allergen>> execute() {
    return _repository.getAllergens();
  }
}
