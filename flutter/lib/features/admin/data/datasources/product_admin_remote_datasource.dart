import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eco_bocado/core/utils/app_services.dart';
import 'package:eco_bocado/features/admin/domain/entities/product_admin.dart';

class ProductAdminRemoteDataSource {
  final Dio _dio = AppServices.dio;

  /// Obtener todos los productos (incluye inactivos)
  Future<List<ProductAdmin>> getAllProducts() async {
    try {
      final response = await _dio.get('/admin/products');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => ProductAdmin.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Acceso denegado: se requieren permisos de administrador');
      }
      throw Exception(e.response?.data['message'] ?? 'Error al obtener productos');
    }
  }

  /// Obtener un producto por ID
  Future<ProductAdmin> getProductById(int id) async {
    try {
      final response = await _dio.get('/admin/products/$id');
      
      if (response.statusCode == 200) {
        return ProductAdmin.fromJson(response.data);
      } else {
        throw Exception('Error al obtener el producto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener el producto');
    }
  }

  /// Crear un nuevo producto
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
    try {
      final response = await _dio.post(
        '/admin/products',
        data: {
          'nameEs': nameEs,
          'nameEn': nameEn,
          'descriptionEs': descriptionEs,
          'descriptionEn': descriptionEn,
          'price': price,
          'currency': currency,
          'isVegan': isVegan,
          'categoryId': categoryId,
        },
      );
      
      if (response.statusCode == 201) {
        return ProductAdmin.fromJson(response.data);
      } else {
        throw Exception('Error al crear el producto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al crear el producto');
    }
  }

  /// Actualizar un producto existente
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
    try {
      final Map<String, dynamic> data = {};
      
      if (nameEs != null) data['nameEs'] = nameEs;
      if (nameEn != null) data['nameEn'] = nameEn;
      if (descriptionEs != null) data['descriptionEs'] = descriptionEs;
      if (descriptionEn != null) data['descriptionEn'] = descriptionEn;
      if (price != null) data['price'] = price;
      if (currency != null) data['currency'] = currency;
      if (isVegan != null) data['isVegan'] = isVegan;
      if (categoryId != null) data['categoryId'] = categoryId;

      final response = await _dio.patch(
        '/admin/products/$id',
        data: data,
      );
      
      if (response.statusCode == 200) {
        return ProductAdmin.fromJson(response.data);
      } else {
        throw Exception('Error al actualizar el producto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar el producto');
    }
  }

  /// Eliminar un producto (soft delete)
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/admin/products/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar el producto');
    }
  }

  /// Reactivar un producto
  Future<ProductAdmin> reactivateProduct(int id) async {
    try {
      final response = await _dio.patch('/admin/products/$id/reactivate');
      
      if (response.statusCode == 200) {
        return ProductAdmin.fromJson(response.data);
      } else {
        throw Exception('Error al reactivar el producto: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al reactivar el producto');
    }
  }

  /// Obtener todas las categorías (usa el endpoint de shop)
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _dio.get('/products/categories');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al obtener categorías: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener categorías');
    }
  }

  /// Obtener todos los alérgenos disponibles
  Future<List<Map<String, dynamic>>> getAllergens() async {
    try {
      final response = await _dio.get('/products/allergens');
      
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al obtener alérgenos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al obtener categorías');
    }
  }

  /// Subir imagen para un producto
  /// [imageData] debe ser XFile para soportar tanto web como mobile
  Future<String> uploadProductImage(int productId, dynamic imageData) async {
    try {
      MultipartFile multipartFile;
      
      // Si es XFile (web o mobile), usar readAsBytes
      if (imageData is XFile) {
        final bytes = await imageData.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: imageData.name,
        );
      } else if (imageData is String) {
        // Fallback para path directo (mobile)
        multipartFile = await MultipartFile.fromFile(imageData);
      } else {
        throw Exception('Tipo de imagen no soportado');
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        'productId': productId, // Enviar como número
      });

      final response = await _dio.post(
        '/media/upload',
        data: formData,
      );
      
      if (response.statusCode == 201) {
        return response.data['path'] as String;
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al subir imagen');
    }
  }

  /// Eliminar imagen por ID
  Future<void> deleteProductImage(int imageId) async {
    try {
      final response = await _dio.delete('/media/$imageId');
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar imagen: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al eliminar imagen');
    }
  }

  /// Actualizar alérgenos de un producto
  Future<void> updateProductAllergens(int productId, List<Map<String, dynamic>> allergens) async {
    try {
      final response = await _dio.patch(
        '/admin/products/$productId/allergens',
        data: {'allergens': allergens},
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al actualizar alérgenos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error al actualizar alérgenos');
    }
  }
}
