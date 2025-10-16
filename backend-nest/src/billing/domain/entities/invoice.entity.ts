export type InvoiceStatus = 'requested' | 'issued' | 'cancelled';

export class Invoice {
  readonly id: number;
  readonly uuid: string | null;

  readonly userId: number;
  readonly orderId: number;

  readonly number: string | null;       // número de factura (único cuando se emite)
  readonly status: InvoiceStatus;       // requested|issued|cancelled

  readonly total: number;
  readonly issuedAt: Date | null;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string | null;
    userId: number;
    orderId: number;
    number: string | null;
    status: InvoiceStatus;
    total: number;
    issuedAt: Date | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid ?? null;
    this.userId = props.userId;
    this.orderId = props.orderId;
    this.number = props.number ?? null;
    this.status = props.status;
    this.total = props.total;
    this.issuedAt = props.issuedAt ?? null;
    this.isActive = props.isActive;
    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string | null;
    userId: number;
    orderId: number;
    number: string | null;
    status: InvoiceStatus;
    total: number;
    issuedAt: Date | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): Invoice {
    return new Invoice({
      id: p.id,
      uuid: p.uuid ?? null,
      userId: p.userId,
      orderId: p.orderId,
      number: p.number ?? null,
      status: p.status,
      total: p.total,
      issuedAt: p.issuedAt ?? null,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}