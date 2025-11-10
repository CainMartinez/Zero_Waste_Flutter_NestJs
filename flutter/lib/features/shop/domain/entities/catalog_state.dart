import 'catalog_item.dart';

/// Estado del catálogo con items, paginación y loading
class CatalogState {
  final List<CatalogItem> items;
  final bool isLoading;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  const CatalogState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.nextCursor,
    this.error,
  });

  CatalogState copyWith({
    List<CatalogItem>? items,
    bool? isLoading,
    bool? hasMore,
    String? nextCursor,
    String? error,
  }) {
    return CatalogState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      error: error ?? this.error,
    );
  }

  /// Estado inicial vacío
  factory CatalogState.initial() {
    return const CatalogState();
  }

  /// Estado de carga
  CatalogState loading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Estado con error
  CatalogState withError(String error) {
    return copyWith(isLoading: false, error: error);
  }

  /// Estado con datos cargados
  CatalogState withData({
    required List<CatalogItem> items,
    required bool hasMore,
    String? nextCursor,
  }) {
    return copyWith(
      items: items,
      isLoading: false,
      hasMore: hasMore,
      nextCursor: nextCursor,
      error: null,
    );
  }
}
