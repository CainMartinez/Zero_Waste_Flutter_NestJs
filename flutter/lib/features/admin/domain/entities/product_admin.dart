import 'package:flutter/material.dart';

class ProductImage {
  final int id;
  final String path;
  final String fileName;

  ProductImage({
    required this.id,
    required this.path,
    required this.fileName,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int,
      path: json['path'] as String,
      fileName: json['fileName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'fileName': fileName,
    };
  }
}

class ProductAllergen {
  final String code;
  final String nameEs;
  final String nameEn;
  final bool contains;
  final bool mayContain;

  ProductAllergen({
    required this.code,
    required this.nameEs,
    required this.nameEn,
    required this.contains,
    required this.mayContain,
  });

  factory ProductAllergen.fromJson(Map<String, dynamic> json) {
    return ProductAllergen(
      code: json['code'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
      contains: _parseBool(json['contains']),
      mayContain: _parseBool(json['mayContain']),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nameEs': nameEs,
      'nameEn': nameEn,
      'contains': contains,
      'mayContain': mayContain,
    };
  }
}

class ProductAdmin {
  final int id;
  final String uuid;
  final String nameEs;
  final String nameEn;
  final String descriptionEs;
  final String descriptionEn;
  final double price;
  final String currency;
  final bool isVegan;
  final bool isActive;
  final int? categoryId;
  final String? categoryCode;
  final String? categoryNameEs;
  final String? categoryNameEn;
  final List<ProductImage> images;
  final List<ProductAllergen> allergens;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductAdmin({
    required this.id,
    required this.uuid,
    required this.nameEs,
    required this.nameEn,
    required this.descriptionEs,
    required this.descriptionEn,
    required this.price,
    required this.currency,
    required this.isVegan,
    required this.isActive,
    this.categoryId,
    this.categoryCode,
    this.categoryNameEs,
    this.categoryNameEn,
    this.images = const [],
    this.allergens = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductAdmin.fromJson(Map<String, dynamic> json) {
    return ProductAdmin(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
      descriptionEs: json['descriptionEs'] as String,
      descriptionEn: json['descriptionEn'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      isVegan: _parseBool(json['isVegan']),
      isActive: _parseBool(json['isActive']),
      categoryId: json['categoryId'] as int?,
      categoryCode: json['categoryCode'] as String?,
      categoryNameEs: json['categoryNameEs'] as String?,
      categoryNameEn: json['categoryNameEn'] as String?,
      images: json['images'] != null
          ? (json['images'] as List).map((img) => ProductImage.fromJson(img)).toList()
          : [],
      allergens: json['allergens'] != null
          ? (json['allergens'] as List).map((a) => ProductAllergen.fromJson(a)).toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }

  String description(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? descriptionEn : descriptionEs;
  }

  String? categoryName(BuildContext context) {
    if (categoryNameEs == null || categoryNameEn == null) return null;
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? categoryNameEn : categoryNameEs;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'nameEs': nameEs,
      'nameEn': nameEn,
      'descriptionEs': descriptionEs,
      'descriptionEn': descriptionEn,
      'price': price,
      'currency': currency,
      'isVegan': isVegan,
      'isActive': isActive,
      'categoryId': categoryId,
      'categoryCode': categoryCode,
      'categoryNameEs': categoryNameEs,
      'categoryNameEn': categoryNameEn,
      'images': images.map((img) => img.toJson()).toList(),
      'allergens': allergens.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductAdmin copyWith({
    int? id,
    String? uuid,
    String? nameEs,
    String? nameEn,
    String? descriptionEs,
    String? descriptionEn,
    double? price,
    String? currency,
    bool? isVegan,
    bool? isActive,
    int? categoryId,
    String? categoryCode,
    String? categoryNameEs,
    String? categoryNameEn,
    List<ProductImage>? images,
    List<ProductAllergen>? allergens,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductAdmin(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      nameEs: nameEs ?? this.nameEs,
      nameEn: nameEn ?? this.nameEn,
      descriptionEs: descriptionEs ?? this.descriptionEs,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isVegan: isVegan ?? this.isVegan,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryNameEs: categoryNameEs ?? this.categoryNameEs,
      categoryNameEn: categoryNameEn ?? this.categoryNameEn,
      images: images ?? this.images,
      allergens: allergens ?? this.allergens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
