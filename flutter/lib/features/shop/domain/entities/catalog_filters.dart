/// Filtros para el catálogo
class CatalogFilters {
  final String? categoryCode;
  final bool? isVegan;
  final List<String>? excludeAllergens;
  final String? sortBy; // 'price', 'name', 'createdAt'
  final String? sortOrder; // 'asc', 'desc'
  final int? cursor;
  final int? limit;

  const CatalogFilters({
    this.categoryCode,
    this.isVegan,
    this.excludeAllergens,
    this.sortBy,
    this.sortOrder,
    this.cursor,
    this.limit,
  });

  CatalogFilters copyWith({
    String? categoryCode,
    bool? isVegan,
    List<String>? excludeAllergens,
    String? sortBy,
    String? sortOrder,
    int? cursor,
    int? limit,
  }) {
    return CatalogFilters(
      categoryCode: categoryCode ?? this.categoryCode,
      isVegan: isVegan ?? this.isVegan,
      excludeAllergens: excludeAllergens ?? this.excludeAllergens,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      cursor: cursor ?? this.cursor,
      limit: limit ?? this.limit,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (categoryCode != null) params['categoryCode'] = categoryCode;
    if (isVegan != null) params['isVegan'] = isVegan;
    if (excludeAllergens != null && excludeAllergens!.isNotEmpty) {
      params['excludeAllergens'] = excludeAllergens;
    }
    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (cursor != null) params['cursor'] = cursor;
    if (limit != null) params['limit'] = limit;
    
    return params;
  }
}
