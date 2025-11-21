import { Product } from '../entities/product.entity';
import { RescueMenu } from '../entities/rescue-menu.entity';

export interface AllergenInfo {
  code: string;
  nameEs: string;
  nameEn: string;
  contains: boolean;
  mayContain: boolean;
}

export interface CategoryInfo {
  code: string;
  nameEs: string;
  nameEn: string;
}

/**
 * Producto con información adicional de alérgenos e imágenes
 */
export type ProductWithDetails = Product & {
  allergens: AllergenInfo[];
  images: string[];
  category: CategoryInfo;
};

/**
 * Menú con información adicional de alérgenos e imágenes
 */
export type MenuWithDetails = RescueMenu & {
  allergens: AllergenInfo[];
  images: string[];
  category: CategoryInfo;
};
