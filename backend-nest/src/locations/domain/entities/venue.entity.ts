export class Venue {
  readonly id: number;
  readonly uuid: string | null;

  readonly code: string | null;     // puede ser null si no lo usas aún
  readonly name: string | null;

  readonly timezone: string;        // por defecto 'Europe/Madrid' en BD
  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string | null;
    code: string | null;
    name: string | null;
    timezone: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid ?? null;

    this.code = props.code ?? null;
    this.name = props.name ?? null;

    this.timezone = props.timezone;
    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string | null;
    code: string | null;
    name: string | null;
    timezone: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): Venue {
    return new Venue({
      id: p.id,
      uuid: p.uuid ?? null,
      code: p.code ?? null,
      name: p.name ?? null,
      timezone: p.timezone,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}