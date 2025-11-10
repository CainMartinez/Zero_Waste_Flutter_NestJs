export interface AllergenInfo {
  code: string;
  nameEs: string;
  nameEn: string;
}

export interface CategoryInfo {
  code: string;
  nameEs: string;
  nameEn: string;
}

/**
 * Entidad unificada que representa un elemento del catálogo
 * Puede ser un Product o un RescueMenu
 */
export class CatalogItem {
  readonly id: number;
  readonly uuid: string;
  readonly type: 'product' | 'menu';
  
  readonly nameEs: string;
  readonly nameEn: string;
  readonly descriptionEs: string;
  readonly descriptionEn: string;
  
  readonly price: number;
  readonly currency: string;
  readonly isVegan: boolean;
  
  readonly category: CategoryInfo; // Categoría con nombres
  readonly allergens: AllergenInfo[]; // Alérgenos con nombres
  readonly images: string[]; // URLs de imágenes
  
  // Solo para menús
  readonly menuComposition?: {
    drinkId: number;
    starterId: number;
    mainId: number;
    dessertId: number;
  };
  
  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string;
    type: 'product' | 'menu';
    nameEs: string;
    nameEn: string;
    descriptionEs: string;
    descriptionEn: string;
    price: number;
    currency: string;
    isVegan: boolean;
    category: CategoryInfo;
    allergens: AllergenInfo[];
    images: string[];
    menuComposition?: {
      drinkId: number;
      starterId: number;
      mainId: number;
      dessertId: number;
    };
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid;
    this.type = props.type;
    this.nameEs = props.nameEs;
    this.nameEn = props.nameEn;
    this.descriptionEs = props.descriptionEs;
    this.descriptionEn = props.descriptionEn;
    this.price = props.price;
    this.currency = props.currency;
    this.isVegan = props.isVegan;
    this.category = props.category;
    this.allergens = props.allergens;
    this.images = props.images;
    this.menuComposition = props.menuComposition;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  /**
   * Crea un CatalogItem desde un Product
   */
  static fromProduct(product: any, category: CategoryInfo, allergens: AllergenInfo[], images: string[]): CatalogItem {
    return new CatalogItem({
      id: product.id,
      uuid: product.uuid || '',
      type: 'product',
      nameEs: product.nameEs || '',
      nameEn: product.nameEn || '',
      descriptionEs: product.descriptionEs || '',
      descriptionEn: product.descriptionEn || '',
      price: product.price,
      currency: product.currency,
      isVegan: product.isVegan,
      category,
      allergens,
      images,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    });
  }

  /**
   * Crea un CatalogItem desde un RescueMenu
   */
  static fromMenu(menu: any, category: CategoryInfo, allergens: AllergenInfo[], images: string[]): CatalogItem {
    return new CatalogItem({
      id: menu.id,
      uuid: menu.uuid || '',
      type: 'menu',
      nameEs: menu.nameEs || '',
      nameEn: menu.nameEn || '',
      descriptionEs: menu.descriptionEs || '',
      descriptionEn: menu.descriptionEn || '',
      price: menu.price,
      currency: menu.currency,
      isVegan: menu.isVegan,
      category,
      allergens,
      images,
      menuComposition: {
        drinkId: menu.drinkProductId,
        starterId: menu.starterProductId,
        mainId: menu.mainProductId,
        dessertId: menu.dessertProductId,
      },
      createdAt: menu.createdAt,
      updatedAt: menu.updatedAt,
    });
  }
}
