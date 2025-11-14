import { Product } from '../../../shop/domain/entities/product.entity';

export abstract class IProductAdminRepository {
  /**
   * Obtiene todos los productos (incluyendo inactivos)
   */
  abstract findAll(): Promise<Product[]>;

  /**
   * Obtiene un producto por su ID
   */
  abstract findById(id: number): Promise<Product | null>;

  /**
   * Obtiene un producto por su UUID
   */
  abstract findByUuid(uuid: string): Promise<Product | null>;

  /**
   * Crea un nuevo producto
   */
  abstract create(product: Partial<Product> & { categoryId: number }): Promise<Product>;

  /**
   * Actualiza un producto existente
   */
  abstract update(id: number, product: Partial<Product> & { categoryId?: number }): Promise<Product>;

  /**
   * Elimina un producto (soft delete)
   */
  abstract softDelete(id: number): Promise<void>;

  /**
   * Reactiva un producto
   */
  abstract reactivate(id: number): Promise<Product>;
}
