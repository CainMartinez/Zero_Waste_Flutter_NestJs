/**
 * Entidad de dominio para una imagen
 */
export class Image {
  id?: number;
  slug: string; // Identificador único en formato: {bucket}-{timestamp}-{nombre}
  fileName: string;
  path: string; // Ruta relativa: /images/products/file.jpg
  mimeType: string;
  size: number;
  productId?: number; // FK a products.id
  menuId?: number; // FK a rescue_menus.id
  isActive: boolean;
  createdAt?: Date;
  updatedAt?: Date;

  constructor(partial: Partial<Image>) {
    Object.assign(this, partial);
  }

  /**
   * Genera la URL completa usando la base URL
   */
  getFullUrl(baseUrl: string): string {
    return `${baseUrl}${this.path}`;
  }
}
