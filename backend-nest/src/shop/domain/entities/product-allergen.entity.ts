export class ProductAllergen {
  readonly id: number;
  readonly productId: number;
  readonly allergenCode: string;

  readonly contains: boolean;
  readonly mayContain: boolean;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    productId: number;
    allergenCode: string;
    contains: boolean;
    mayContain: boolean;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.productId = props.productId;
    this.allergenCode = props.allergenCode;
    this.contains = props.contains;
    this.mayContain = props.mayContain;
    this.isActive = props.isActive;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    productId: number;
    allergenCode: string;
    contains: boolean;
    mayContain: boolean;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): ProductAllergen {
    return new ProductAllergen({
      id: p.id,
      productId: p.productId,
      allergenCode: p.allergenCode,
      contains: p.contains,
      mayContain: p.mayContain,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}