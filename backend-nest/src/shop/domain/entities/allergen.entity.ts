export class Allergen {
  readonly code: string;           // PK (e.g., 'gluten', 'lactose', 'nuts')
  readonly nameEs: string | null;
  readonly nameEn: string | null;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    code: string;
    nameEs: string | null;
    nameEn: string | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.code = props.code;
    this.nameEs = props.nameEs ?? null;
    this.nameEn = props.nameEn ?? null;
    this.isActive = props.isActive;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    code: string;
    nameEs: string | null;
    nameEn: string | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): Allergen {
    return new Allergen({
      code: p.code,
      nameEs: p.nameEs ?? null,
      nameEn: p.nameEn ?? null,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}