import 'package:eco_bocado/features/admin/domain/entities/product_admin.dart';

abstract class ProductAdminRepository {
  Future<List<ProductAdmin>> getAllProducts();
  Future<ProductAdmin> getProductById(int id);
  Future<ProductAdmin> createProduct({
    required String nameEs,
    required String nameEn,
    required String descriptionEs,
    required String descriptionEn,
    required double price,
    String currency,
    bool isVegan,
    required int categoryId,
  });
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
  });
  Future<void> deleteProduct(int id);
  Future<ProductAdmin> reactivateProduct(int id);
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<Map<String, dynamic>>> getAllergens();
  Future<String> uploadProductImage(int productId, dynamic imageData);
  Future<void> deleteProductImage(int imageId);
  Future<void> updateProductAllergens(int productId, List<Map<String, dynamic>> allergens);
}
