import 'package:eco_bocado/features/admin/data/datasources/product_admin_remote_datasource.dart';
import 'package:eco_bocado/features/admin/domain/entities/product_admin.dart';
import 'package:eco_bocado/features/admin/domain/repositories/product_admin_repository.dart';

class ProductAdminRepositoryImpl implements ProductAdminRepository {
  final ProductAdminRemoteDataSource _remoteDataSource;

  ProductAdminRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductAdmin>> getAllProducts() async {
    return await _remoteDataSource.getAllProducts();
  }

  @override
  Future<ProductAdmin> getProductById(int id) async {
    return await _remoteDataSource.getProductById(id);
  }

  @override
  Future<ProductAdmin> createProduct({
    required String nameEs,
    required String nameEn,
    required String descriptionEs,
    required String descriptionEn,
    required double price,
    String currency = 'EUR',
    bool isVegan = false,
    required int categoryId,
  }) async {
    return await _remoteDataSource.createProduct(
      nameEs: nameEs,
      nameEn: nameEn,
      descriptionEs: descriptionEs,
      descriptionEn: descriptionEn,
      price: price,
      currency: currency,
      isVegan: isVegan,
      categoryId: categoryId,
    );
  }

  @override
  Future<ProductAdmin> updateProduct({
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
    return await _remoteDataSource.updateProduct(
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
  }

  @override
  Future<void> deleteProduct(int id) async {
    return await _remoteDataSource.deleteProduct(id);
  }

  @override
  Future<ProductAdmin> reactivateProduct(int id) async {
    return await _remoteDataSource.reactivateProduct(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _remoteDataSource.getCategories();
  }

  @override
  Future<String> uploadProductImage(int productId, dynamic imageData) async {
    return await _remoteDataSource.uploadProductImage(productId, imageData);
  }

  @override
  Future<void> deleteProductImage(int imageId) async {
    return await _remoteDataSource.deleteProductImage(imageId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllergens() async {
    return await _remoteDataSource.getAllergens();
  }

  @override
  Future<void> updateProductAllergens(int productId, List<Map<String, dynamic>> allergens) async {
    return await _remoteDataSource.updateProductAllergens(productId, allergens);
  }
}
