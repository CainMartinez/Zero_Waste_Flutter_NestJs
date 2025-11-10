import { Product } from '../entities/product.entity';
import { CatalogFilters, PaginatedResult } from '../types/catalog-filters.type';
import { ProductWithDetails } from '../types/catalog-types.type';

export abstract class IProductRepository {
  abstract findAllVisible(): Promise<Product[]>;
  
  /**
   * Busca productos con filtros y paginación
   * @param filters - Filtros de búsqueda
   * @returns Resultado paginado con productos, alérgenos e imágenes
   */
  abstract findWithFilters(filters: CatalogFilters): Promise<PaginatedResult<ProductWithDetails>>;
}