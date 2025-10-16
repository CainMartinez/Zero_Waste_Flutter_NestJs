export class LoyaltyRedemption {
  readonly id: number;
  readonly userId: number;
  readonly ruleId: number;
  readonly rescueMenuId: number;
  readonly orderId: number | null;

  readonly redeemedAt: Date;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    userId: number;
    ruleId: number;
    rescueMenuId: number;
    orderId: number | null;
    redeemedAt: Date;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.ruleId = props.ruleId;
    this.rescueMenuId = props.rescueMenuId;
    this.orderId = props.orderId ?? null;
    this.redeemedAt = props.redeemedAt;
    this.isActive = props.isActive;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    userId: number;
    ruleId: number;
    rescueMenuId: number;
    orderId: number | null;
    redeemedAt: Date;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): LoyaltyRedemption {
    return new LoyaltyRedemption({
      id: p.id,
      userId: p.userId,
      ruleId: p.ruleId,
      rescueMenuId: p.rescueMenuId,
      orderId: p.orderId ?? null,
      redeemedAt: p.redeemedAt,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}