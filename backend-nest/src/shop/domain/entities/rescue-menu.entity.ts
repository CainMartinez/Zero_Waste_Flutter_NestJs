export class RescueMenu {
  readonly id: number;
  readonly uuid: string | null;

  readonly nameEs: string | null;
  readonly nameEn: string | null;

  readonly descriptionEs: string | null;
  readonly descriptionEn: string | null;

  readonly drinkProductId: number;    // FK -> products.id
  readonly starterProductId: number;  // FK -> products.id
  readonly mainProductId: number;     // FK -> products.id
  readonly dessertProductId: number;  // FK -> products.id

  readonly price: number;
  readonly currency: string;          // 'EUR'
  readonly isVegan: boolean;
  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string | null;
    nameEs: string | null;
    nameEn: string | null;
    descriptionEs: string | null;
    descriptionEn: string | null;
    drinkProductId: number;
    starterProductId: number;
    mainProductId: number;
    dessertProductId: number;
    price: number;
    currency: string;
    isVegan: boolean;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid ?? null;

    this.nameEs = props.nameEs ?? null;
    this.nameEn = props.nameEn ?? null;

    this.descriptionEs = props.descriptionEs ?? null;
    this.descriptionEn = props.descriptionEn ?? null;

    this.drinkProductId = props.drinkProductId;
    this.starterProductId = props.starterProductId;
    this.mainProductId = props.mainProductId;
    this.dessertProductId = props.dessertProductId;

    this.price = props.price;
    this.currency = props.currency;
    this.isVegan = props.isVegan;
    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string | null;
    nameEs: string | null;
    nameEn: string | null;
    descriptionEs: string | null;
    descriptionEn: string | null;
    drinkProductId: number;
    starterProductId: number;
    mainProductId: number;
    dessertProductId: number;
    price: number;
    currency: string;
    isVegan: boolean;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): RescueMenu {
    return new RescueMenu({
      id: p.id,
      uuid: p.uuid ?? null,
      nameEs: p.nameEs ?? null,
      nameEn: p.nameEn ?? null,
      descriptionEs: p.descriptionEs ?? null,
      descriptionEn: p.descriptionEn ?? null,
      drinkProductId: p.drinkProductId,
      starterProductId: p.starterProductId,
      mainProductId: p.mainProductId,
      dessertProductId: p.dessertProductId,
      price: p.price,
      currency: p.currency,
      isVegan: p.isVegan,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}