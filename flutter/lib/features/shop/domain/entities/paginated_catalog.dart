import 'catalog_item.dart';

/// Respuesta paginada del catálogo
class PaginatedCatalog {
  final List<CatalogItem> items;
  final int? nextCursor;
  final bool hasMore;
  final int total;
  final int count;

  const PaginatedCatalog({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    required this.total,
    required this.count,
  });

  factory PaginatedCatalog.fromJson(Map<String, dynamic> json) {
    return PaginatedCatalog(
      items: (json['items'] as List<dynamic>)
          .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as int?,
      hasMore: json['hasMore'] as bool,
      total: json['total'] as int,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'nextCursor': nextCursor,
      'hasMore': hasMore,
      'total': total,
      'count': count,
    };
  }
}
