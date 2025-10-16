export class LoyaltyRule {
  readonly id: number;
  readonly uuid: string | null;

  readonly code: string;
  readonly everyNPurchases: number;
  readonly rewardType: string; // 'free_menu', etc.

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string | null;
    code: string;
    everyNPurchases: number;
    rewardType: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid ?? null;
    this.code = props.code;
    this.everyNPurchases = props.everyNPurchases;
    this.rewardType = props.rewardType;
    this.isActive = props.isActive;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string | null;
    code: string;
    everyNPurchases: number;
    rewardType: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): LoyaltyRule {
    return new LoyaltyRule({
      id: p.id,
      uuid: p.uuid ?? null,
      code: p.code,
      everyNPurchases: p.everyNPurchases,
      rewardType: p.rewardType,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}