export interface CatalogFilters {
  categoryCode?: string;
  isVegan?: boolean;
  excludeAllergens?: string[]; // Excluir productos que contengan estos alérgenos
  sortBy?: 'price' | 'name' | 'createdAt';
  sortOrder?: 'asc' | 'desc';
  cursor?: number; // ID del último elemento de la página anterior
  limit?: number;
}

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  nextCursor: number | null;
}
