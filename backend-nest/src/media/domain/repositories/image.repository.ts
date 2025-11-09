import { Image } from '../entities/image.entity';

/**
 * Repositorio de imágenes (interfaz del dominio)
 */
export interface ImageRepository {
  create(image: Image): Promise<Image>;
  findById(id: number): Promise<Image | null>;
  findBySlug(slug: string): Promise<Image | null>;
  findByProductId(productId: number): Promise<Image[]>;
  findByMenuId(menuId: number): Promise<Image[]>;
  update(id: number, image: Partial<Image>): Promise<Image>;
  delete(id: number): Promise<void>;
  deleteBySlug(slug: string): Promise<void>;
}
