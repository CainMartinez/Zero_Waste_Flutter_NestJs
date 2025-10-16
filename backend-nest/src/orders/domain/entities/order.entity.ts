export type OrderStatus = 'draft' | 'confirmed' | 'prepared' | 'delivered' | 'cancelled';

export class Order {
  readonly id: number;
  readonly uuid: string | null;

  readonly userId: number;
  readonly status: OrderStatus;

  readonly pickupSlotId: number | null;

  readonly subtotal: number;
  readonly total: number;
  readonly currency: string; // 'EUR'

  readonly notes: string | null;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string | null;
    userId: number;
    status: OrderStatus;
    pickupSlotId: number | null;
    subtotal: number;
    total: number;
    currency: string;
    notes: string | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid ?? null;

    this.userId = props.userId;
    this.status = props.status;

    this.pickupSlotId = props.pickupSlotId ?? null;

    this.subtotal = props.subtotal;
    this.total = props.total;
    this.currency = props.currency;

    this.notes = props.notes ?? null;

    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string | null;
    userId: number;
    status: OrderStatus;
    pickupSlotId: number | null;
    subtotal: number;
    total: number;
    currency: string;
    notes: string | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): Order {
    return new Order({
      id: p.id,
      uuid: p.uuid ?? null,
      userId: p.userId,
      status: p.status,
      pickupSlotId: p.pickupSlotId ?? null,
      subtotal: p.subtotal,
      total: p.total,
      currency: p.currency,
      notes: p.notes ?? null,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}