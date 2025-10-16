import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Index,
} from 'typeorm';
import { UsersOrmEntity } from '../../../../auth/infrastructure/typeorm/entities-orm/users.orm-entity';
import { OrderOrmEntity } from '../../../../orders/infrastructure/typeorm/entities-orm/order.orm-entity';

@Entity({ name: 'invoices' })
@Index('UQ_invoices_number', ['number'], { unique: true })
export class InvoiceOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'char', length: 36, nullable: true, unique: true })
  uuid: string | null;

  @Column({ name: 'user_id', type: 'int' })
  userId: number;

  @ManyToOne(() => UsersOrmEntity, { eager: false })
  @JoinColumn({ name: 'user_id' })
  user: UsersOrmEntity;

  @Column({ name: 'order_id', type: 'int' })
  orderId: number;

  @ManyToOne(() => OrderOrmEntity, { eager: false })
  @JoinColumn({ name: 'order_id' })
  order: OrderOrmEntity;

  @Column({ type: 'varchar', length: 64, nullable: true, unique: true })
  number: string | null;

  @Column({ type: 'varchar', length: 16, default: () => "'requested'" })
  status: string; // requested|issued|cancelled

  @Column({ type: 'decimal', precision: 10, scale: 2, default: () => '0.00' })
  total: number;

  @Column({ name: 'issued_at', type: 'timestamp', nullable: true })
  issuedAt: Date | null;

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