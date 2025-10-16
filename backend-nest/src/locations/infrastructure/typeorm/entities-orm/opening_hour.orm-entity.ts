import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { VenueOrmEntity } from './venue.orm-entity';

@Entity({ name: 'opening_hours' })
export class OpeningHourOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'venue_id', type: 'int' })
  venueId: number;

  @ManyToOne(() => VenueOrmEntity, { eager: false })
  @JoinColumn({ name: 'venue_id' })
  venue: VenueOrmEntity;

  @Column({ type: 'smallint' })
  weekday: number; // 0=Mon .. 6=Sun

  @Column({ name: 'open_time', type: 'time' })
  openTime: string; // 'HH:MM:SS'

  @Column({ name: 'close_time', type: 'time' })
  closeTime: string; // 'HH:MM:SS'

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