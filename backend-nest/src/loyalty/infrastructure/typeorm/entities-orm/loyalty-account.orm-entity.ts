import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
} from 'typeorm';
import { UsersOrmEntity } from '../../../../auth/infrastructure/typeorm/entities-orm/users.orm-entity';

@Entity({ name: 'loyalty_accounts' })
@Unique('UQ_loyalty_user', ['userId'])
export class LoyaltyAccountOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', type: 'int' })
  userId: number;

  @ManyToOne(() => UsersOrmEntity, { eager: false })
  @JoinColumn({ name: 'user_id' })
  user: UsersOrmEntity;

  @Column({ type: 'int', default: () => '0' })
  points: number;

  @Column({ name: 'purchases_count', type: 'int', default: () => '0' })
  purchasesCount: number;

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