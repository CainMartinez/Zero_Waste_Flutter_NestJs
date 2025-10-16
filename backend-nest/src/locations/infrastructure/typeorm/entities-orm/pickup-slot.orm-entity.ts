import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  Index,
} from 'typeorm';
import { VenueOrmEntity } from './venue.orm-entity';

@Entity({ name: 'pickup_slots' })
@Unique('uq_slot', ['venueId', 'slotDate', 'startTime'])
@Index('idx_pickup_slots_venue', ['venueId'])
export class PickupSlotOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'venue_id', type: 'int' })
  venueId: number;

  @ManyToOne(() => VenueOrmEntity, { eager: false })
  @JoinColumn({ name: 'venue_id' })
  venue: VenueOrmEntity;

  @Column({ name: 'slot_date', type: 'date' })
  slotDate: string; // 'YYYY-MM-DD'

  @Column({ name: 'start_time', type: 'time' })
  startTime: string; // 'HH:MM:SS'

  @Column({ name: 'end_time', type: 'time' })
  endTime: string; // 'HH:MM:SS'

  @Column({ type: 'int', default: () => '1' })
  capacity: number;

  @Column({ name: 'booked_count', type: 'int', default: () => '0' })
  bookedCount: number;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: () => '1' })
  isActive: boolean;

  @Column({
    name: 'created_at',
    type: 'timestamp',
    default: () => 'CURRENT_TIMESTAMP',
  })
  createdAt: Date;

  @Column({
    name: 'updated_at',
    type: 'timestamp',
    default: () => 'CURRENT_TIMESTAMP',
    onUpdate: 'CURRENT_TIMESTAMP',
  })
  updatedAt: Date;
}