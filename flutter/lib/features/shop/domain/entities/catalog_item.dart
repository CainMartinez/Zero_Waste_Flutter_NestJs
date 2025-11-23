import 'package:flutter/material.dart';
import 'menu_composition.dart';
import 'allergen.dart';

/// Información básica de categoría (sin el id)
class CategoryInfo {
  final String code;
  final String nameEs;
  final String nameEn;

  const CategoryInfo({
    required this.code,
    required this.nameEs,
    required this.nameEn,
  });

  /// Retorna el nombre según el idioma del contexto
  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      code: json['code'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
    );
  }
}

/// Item del catálogo (producto o menú)
class CatalogItem {
  final int id;
  final String uuid;
  final String type; // 'product' o 'menu'
  final String nameEs;
  final String nameEn;
  final String descriptionEs;
  final String descriptionEn;
  final double price;
  final String currency;
  final bool isVegan;
  final CategoryInfo category;
  final List<Allergen> allergens;
  final List<String> images;
  final MenuComposition? menuComposition;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CatalogItem({
    required this.id,
    required this.uuid,
    required this.type,
    required this.nameEs,
    required this.nameEn,
    required this.descriptionEs,
    required this.descriptionEn,
    required this.price,
    required this.currency,
    required this.isVegan,
    required this.category,
    required this.allergens,
    required this.images,
    this.menuComposition,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isMenu => type == 'menu';
  bool get isProduct => type == 'product';

  /// Retorna el nombre según el idioma del contexto
  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }

  /// Retorna la descripción según el idioma del contexto
  String description(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? descriptionEn : descriptionEs;
  }

  factory CatalogItem.fromJson(Map<String, dynamic> json) {
    return CatalogItem(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      type: json['type'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
      descriptionEs: json['descriptionEs'] as String,
      descriptionEn: json['descriptionEn'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      isVegan: json['isVegan'] as bool,
      category: CategoryInfo.fromJson(json['category'] as Map<String, dynamic>),
      allergens: (json['allergens'] as List<dynamic>)
          .map((e) => Allergen.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      menuComposition: json['menuComposition'] != null
          ? MenuComposition.fromJson(json['menuComposition'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'type': type,
      'nameEs': nameEs,
      'nameEn': nameEn,
      'descriptionEs': descriptionEs,
      'descriptionEn': descriptionEn,
      'price': price,
      'currency': currency,
      'isVegan': isVegan,
      'category': {
        'code': category.code,
        'nameEs': category.nameEs,
        'nameEn': category.nameEn,
      },
      'allergens': allergens,
      'images': images,
      'menuComposition': menuComposition?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
