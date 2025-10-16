export class OpeningHour {
  readonly id: number;
  readonly venueId: number;

  readonly weekday: number;     // 0=Mon .. 6=Sun
  readonly openTime: string;    // 'HH:MM:SS'
  readonly closeTime: string;   // 'HH:MM:SS'

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    venueId: number;
    weekday: number;
    openTime: string;
    closeTime: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.venueId = props.venueId;

    this.weekday = props.weekday;
    this.openTime = props.openTime;
    this.closeTime = props.closeTime;

    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    venueId: number;
    weekday: number;
    openTime: string;
    closeTime: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): OpeningHour {
    return new OpeningHour({
      id: p.id,
      venueId: p.venueId,
      weekday: p.weekday,
      openTime: p.openTime,
      closeTime: p.closeTime,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}