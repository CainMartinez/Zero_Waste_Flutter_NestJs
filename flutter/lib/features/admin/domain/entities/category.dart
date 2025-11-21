class Category {
  final int id;
  final String code;
  final String nameEs;
  final String nameEn;

  Category({
    required this.id,
    required this.code,
    required this.nameEs,
    required this.nameEn,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      code: json['code'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'nameEs': nameEs,
      'nameEn': nameEn,
    };
  }
}
