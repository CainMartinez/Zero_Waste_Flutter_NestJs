import 'package:flutter/material.dart';

/// Categoría
class Category {
  final int id;
  final String code;
  final String nameEs;
  final String nameEn;

  const Category({
    required this.id,
    required this.code,
    required this.nameEs,
    required this.nameEn,
  });

  /// Retorna el nombre según el idioma del contexto
  String name(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en' ? nameEn : nameEs;
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      code: json['code'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
    );
  }
}
