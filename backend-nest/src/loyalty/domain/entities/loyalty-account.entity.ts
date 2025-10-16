export class LoyaltyAccount {
  readonly id: number;
  readonly userId: number;

  readonly points: number;
  readonly purchasesCount: number;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    userId: number;
    points: number;
    purchasesCount: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.points = props.points;
    this.purchasesCount = props.purchasesCount;
    this.isActive = props.isActive;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    userId: number;
    points: number;
    purchasesCount: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): LoyaltyAccount {
    return new LoyaltyAccount({
      id: p.id,
      userId: p.userId,
      points: p.points,
      purchasesCount: p.purchasesCount,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}