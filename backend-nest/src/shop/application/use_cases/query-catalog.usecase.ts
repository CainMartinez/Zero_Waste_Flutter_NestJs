import { Inject, Injectable } from '@nestjs/common';
import { IProductRepository } from '../../domain/repositories/product.repository';
import { IRescueMenuRepository } from '../../domain/repositories/rescue-menu.repository';
import { CatalogFilters, PaginatedResult } from '../../domain/types/catalog-filters.type';
import { CatalogItem } from '../../domain/entities/catalog-item.entity';
import { ProductWithDetails, MenuWithDetails } from '../../domain/types/catalog-types.type';

/**
 * Query catalog use case
 * Combines products and menus into a unified catalog with filtering and pagination
 */
@Injectable()
export class QueryCatalogUseCase {
  constructor(
    @Inject(IProductRepository)
    private readonly productRepository: IProductRepository,
    @Inject(IRescueMenuRepository)
    private readonly rescueMenuRepository: IRescueMenuRepository,
  ) {}

  /**
   * Execute catalog query
   * @param filters - Catalog filters (category, vegan, allergens, sorting, pagination)
   * @returns Paginated result of catalog items
   */
  async execute(filters: CatalogFilters): Promise<PaginatedResult<CatalogItem>> {
    const MENU_CATEGORY_CODE = 'MENUS';
    const isMenuFilter = filters.categoryCode?.toUpperCase() === MENU_CATEGORY_CODE;
    
    // Si se filtra por MENUS, solo consultar rescue_menu
    // Si se filtra por otra categoría, solo consultar products
    // Si no hay filtro de categoría, consultar ambos
    let productsResult: PaginatedResult<ProductWithDetails>;
    let menusResult: PaginatedResult<MenuWithDetails>;
    
    if (isMenuFilter) {
      // Solo menús
      menusResult = await this.rescueMenuRepository.findWithFilters(filters);
      productsResult = { items: [], total: 0, nextCursor: null };
    } else if (filters.categoryCode) {
      // Solo productos (otra categoría específica)
      productsResult = await this.productRepository.findWithFilters(filters);
      menusResult = { items: [], total: 0, nextCursor: null };
    } else {
      // Sin filtro de categoría: consultar ambos
      [productsResult, menusResult] = await Promise.all([
        this.productRepository.findWithFilters(filters),
        this.rescueMenuRepository.findWithFilters(filters),
      ]);
    }

    // Convert to catalog items
    const productItems = this.convertProductsToCatalogItems(productsResult.items);
    const menuItems = this.convertMenusToCatalogItems(menusResult.items);

    // Combine items
    const allItems = [...productItems, ...menuItems];

    // Sort combined items based on filters
    const sortedItems = this.sortCombinedItems(allItems, filters);

    // Apply pagination to combined results
    const limit = filters.limit || 10;
    const paginatedItems = this.applyPagination(sortedItems, filters.cursor, limit);

    // Calculate total and next cursor
    const total = productsResult.total + menusResult.total;
    const hasMore = paginatedItems.length > limit;
    const items = hasMore ? paginatedItems.slice(0, limit) : paginatedItems;
    const nextCursor = hasMore ? items[items.length - 1].id : null;

    return {
      items,
      total,
      nextCursor,
    };
  }

  /**
   * Convert products to catalog items
   */
  private convertProductsToCatalogItems(products: ProductWithDetails[]): CatalogItem[] {
    return products.map(product => 
      CatalogItem.fromProduct(product, product.category, product.allergens, product.images)
    );
  }

  /**
   * Convert menus to catalog items
   */
  private convertMenusToCatalogItems(menus: MenuWithDetails[]): CatalogItem[] {
    return menus.map(menu => 
      CatalogItem.fromMenu(menu, menu.category, menu.allergens, menu.images)
    );
  }

  /**
   * Sort combined items based on filters
   * This is needed because products and menus are queried separately
   */
  private sortCombinedItems(items: CatalogItem[], filters: CatalogFilters): CatalogItem[] {
    const sortBy = filters.sortBy || 'createdAt';
    const sortOrder = filters.sortOrder || 'desc';

    return items.sort((a, b) => {
      let comparison = 0;

      switch (sortBy) {
        case 'price':
          comparison = a.price - b.price;
          break;
        case 'name':
          const nameA = a.nameEs || a.nameEn || '';
          const nameB = b.nameEs || b.nameEn || '';
          comparison = nameA.localeCompare(nameB);
          break;
        case 'createdAt':
          comparison = a.createdAt.getTime() - b.createdAt.getTime();
          break;
      }

      // Apply sort order
      if (sortOrder === 'desc') {
        comparison = -comparison;
      }

      // Secondary sort by ID for consistency
      if (comparison === 0) {
        comparison = a.id - b.id;
      }

      return comparison;
    });
  }

  /**
   * Apply cursor pagination to sorted items
   */
  private applyPagination(
    items: CatalogItem[],
    cursor: number | undefined,
    limit: number,
  ): CatalogItem[] {
    // If cursor is provided, filter items after cursor
    const startIndex = cursor 
      ? items.findIndex(item => item.id === cursor) + 1 
      : 0;

    // Return limit + 1 items to check if there are more
    return items.slice(startIndex, startIndex + limit + 1);
  }
}
