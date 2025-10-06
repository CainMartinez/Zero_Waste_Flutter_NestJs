import { Category } from './category.model';

export class Product {
  readonly id: number;
  readonly uuid: string;

  readonly nameEs: string;
  readonly nameEn: string;

  readonly descriptionEs: string;
  readonly descriptionEn: string;

  readonly price: number;
  readonly currency: string;

  readonly isVegan: boolean;
  readonly isActive: boolean;

  readonly category?: Category;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string;
    nameEs: string;
    nameEn: string;
    descriptionEs: string;
    descriptionEn: string;
    price: number;
    currency: string;
    isVegan: boolean;
    isActive: boolean;
    category?: Category;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid;

    this.nameEs = props.nameEs;
    this.nameEn = props.nameEn;

    this.descriptionEs = props.descriptionEs;
    this.descriptionEn = props.descriptionEn;

    this.price = props.price;
    this.currency = props.currency;

    this.isVegan = props.isVegan;
    this.isActive = props.isActive;

    this.category = props.category;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string;
    nameEs: string;
    nameEn: string;
    descriptionEs: string;
    descriptionEn: string;
    price: number;
    currency: string;
    isVegan: boolean;
    isActive: boolean;
    categoryCode?: string;
    createdAt: Date;
    updatedAt: Date;
  }): Product {
    const category = p.categoryCode ? new Category(p.categoryCode) : undefined;
    return new Product({
      id: p.id,
      uuid: p.uuid,
      nameEs: p.nameEs,
      nameEn: p.nameEn,
      descriptionEs: p.descriptionEs,
      descriptionEn: p.descriptionEn,
      price: p.price,
      currency: p.currency,
      isVegan: p.isVegan,
      isActive: p.isActive,
      category,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}