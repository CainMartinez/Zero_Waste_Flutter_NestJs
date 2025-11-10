/// Composición de un menú rescue
class MenuComposition {
  final int drinkId;
  final int starterId;
  final int mainId;
  final int dessertId;

  const MenuComposition({
    required this.drinkId,
    required this.starterId,
    required this.mainId,
    required this.dessertId,
  });

  factory MenuComposition.fromJson(Map<String, dynamic> json) {
    return MenuComposition(
      drinkId: json['drinkId'] as int,
      starterId: json['starterId'] as int,
      mainId: json['mainId'] as int,
      dessertId: json['dessertId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'drinkId': drinkId,
      'starterId': starterId,
      'mainId': mainId,
      'dessertId': dessertId,
    };
  }
}
