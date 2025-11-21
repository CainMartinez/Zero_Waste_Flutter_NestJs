class Allergen {
  final String code;
  final String nameEs;
  final String nameEn;

  Allergen({
    required this.code,
    required this.nameEs,
    required this.nameEn,
  });

  factory Allergen.fromJson(Map<String, dynamic> json) {
    return Allergen(
      code: json['code'] as String,
      nameEs: json['nameEs'] as String,
      nameEn: json['nameEn'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nameEs': nameEs,
      'nameEn': nameEn,
    };
  }
}
