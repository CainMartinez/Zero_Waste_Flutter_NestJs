import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/shop_api_client.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../domain/entities/catalog_filters.dart';
import '../../domain/entities/catalog_state.dart';
import '../../domain/repositories/shop_repository.dart';
import '../../domain/usecases/get_catalog_usecase.dart';
import '../../domain/usecases/get_allergens_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';

/// Provider del API client
final shopApiClientProvider = Provider<ShopApiClient>((ref) {
  return ShopApiClient();
});

/// Provider del repositorio
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final apiClient = ref.watch(shopApiClientProvider);
  return ShopRepositoryImpl(apiClient: apiClient);
});

/// Provider de casos de uso
final getCatalogUseCaseProvider = Provider<GetCatalogUseCase>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return GetCatalogUseCase(repository);
});

final getAllergensUseCaseProvider = Provider<GetAllergensUseCase>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return GetAllergensUseCase(repository);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(shopRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

/// Notificador del catálogo con paginación
class CatalogNotifier extends Notifier<CatalogState> {
  CatalogFilters _currentFilters = const CatalogFilters(limit: 20);

  @override
  CatalogState build() => CatalogState.initial();

  GetCatalogUseCase get _getCatalogUseCase => ref.read(getCatalogUseCaseProvider);

  /// Carga inicial del catálogo
  Future<void> loadCatalog(CatalogFilters filters) async {
    _currentFilters = filters.copyWith(limit: 20, cursor: null);
    state = state.loading();

    try {
      final result = await _getCatalogUseCase.execute(_currentFilters);
      state = state.withData(
        items: result.items,
        hasMore: result.hasMore,
        nextCursor: result.nextCursor?.toString(),
      );
    } catch (e) {
      state = state.withError(e.toString());
    }
  }

  /// Carga más items (infinite scroll)
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.nextCursor == null) return;

    state = state.loading();

    try {
      final filters = _currentFilters.copyWith(cursor: int.tryParse(state.nextCursor ?? ''));
      final result = await _getCatalogUseCase.execute(filters);

      state = state.withData(
        items: [...state.items, ...result.items],
        hasMore: result.hasMore,
        nextCursor: result.nextCursor?.toString(),
      );
    } catch (e) {
      state = state.withError(e.toString());
    }
  }
}

/// Provider del catálogo
final catalogProvider = NotifierProvider<CatalogNotifier, CatalogState>(() {
  return CatalogNotifier();
});

/// Provider de alérgenos
final allergensProvider = FutureProvider((ref) async {
  final useCase = ref.watch(getAllergensUseCaseProvider);
  return await useCase.execute();
});

/// Provider de categorías
final categoriesProvider = FutureProvider((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return await useCase.execute();
});
