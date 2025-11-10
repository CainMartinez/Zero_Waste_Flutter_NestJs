import { RescueMenu } from '../entities/rescue-menu.entity';
import { CatalogFilters, PaginatedResult } from '../types/catalog-filters.type';
import { MenuWithDetails } from '../types/catalog-types.type';

export abstract class IRescueMenuRepository {
  /**
   * Busca menús con filtros y paginación
   * Los menús se filtran igual que los productos
   * Los alérgenos se calculan a partir de todos los productos que componen el menú
   * @param filters - Filtros de búsqueda
   * @returns Resultado paginado con menús, alérgenos e imágenes
   */
  abstract findWithFilters(filters: CatalogFilters): Promise<PaginatedResult<MenuWithDetails>>;
}
