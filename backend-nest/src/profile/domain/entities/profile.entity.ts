export class Profile {
  readonly id: number;
  readonly userId: number;

  readonly phone: string | null;
  readonly addressLine1: string | null;
  readonly addressLine2: string | null;
  readonly city: string | null;
  readonly postalCode: string | null;
  readonly countryCode: string; // 'ES' por defecto en BD

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    userId: number;
    phone: string | null;
    addressLine1: string | null;
    addressLine2: string | null;
    city: string | null;
    postalCode: string | null;
    countryCode: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.userId = props.userId;

    this.phone = props.phone ?? null;
    this.addressLine1 = props.addressLine1 ?? null;
    this.addressLine2 = props.addressLine2 ?? null;
    this.city = props.city ?? null;
    this.postalCode = props.postalCode ?? null;
    this.countryCode = props.countryCode;

    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    userId: number;
    phone: string | null;
    addressLine1: string | null;
    addressLine2: string | null;
    city: string | null;
    postalCode: string | null;
    countryCode: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): Profile {
    return new Profile({
      id: p.id,
      userId: p.userId,
      phone: p.phone ?? null,
      addressLine1: p.addressLine1 ?? null,
      addressLine2: p.addressLine2 ?? null,
      city: p.city ?? null,
      postalCode: p.postalCode ?? null,
      countryCode: p.countryCode,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}