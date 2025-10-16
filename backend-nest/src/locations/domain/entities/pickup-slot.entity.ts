export class PickupSlot {
  readonly id: number;
  readonly venueId: number;

  // Usamos string para mantener formato exacto de BD/API
  readonly slotDate: string;   // 'YYYY-MM-DD'
  readonly startTime: string;  // 'HH:MM:SS'
  readonly endTime: string;    // 'HH:MM:SS'

  readonly capacity: number;     // default 1
  readonly bookedCount: number;  // default 0

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    venueId: number;
    slotDate: string;
    startTime: string;
    endTime: string;
    capacity: number;
    bookedCount: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.venueId = props.venueId;

    this.slotDate = props.slotDate;
    this.startTime = props.startTime;
    this.endTime = props.endTime;

    this.capacity = props.capacity;
    this.bookedCount = props.bookedCount;

    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    venueId: number;
    slotDate: string;
    startTime: string;
    endTime: string;
    capacity: number;
    bookedCount: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): PickupSlot {
    return new PickupSlot({
      id: p.id,
      venueId: p.venueId,
      slotDate: p.slotDate,
      startTime: p.startTime,
      endTime: p.endTime,
      capacity: p.capacity,
      bookedCount: p.bookedCount,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}