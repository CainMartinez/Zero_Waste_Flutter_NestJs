import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Index,
} from 'typeorm';
import { OrderOrmEntity } from './order.orm-entity';
import { ProductOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/product.orm-entity';
import { RescueMenuOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/rescue-menu.orm-entity';

@Entity({ name: 'order_items' })
@Index('idx_order_items_order_id', ['orderId'])
export class OrderItemOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'order_id', type: 'int' })
  orderId: number;

  @ManyToOne(() => OrderOrmEntity, { eager: false })
  @JoinColumn({ name: 'order_id' })
  order: OrderOrmEntity;

  @Column({ name: 'item_type', type: 'varchar', length: 16 })
  itemType: string; // 'product' | 'rescue_menu'

  @Column({ name: 'product_id', type: 'int', nullable: true })
  productId: number | null;

  @ManyToOne(() => ProductOrmEntity, { eager: false })
  @JoinColumn({ name: 'product_id' })
  product: ProductOrmEntity;

  @Column({ name: 'rescue_menu_id', type: 'int', nullable: true })
  rescueMenuId: number | null;

  @ManyToOne(() => RescueMenuOrmEntity, { eager: false })
  @JoinColumn({ name: 'rescue_menu_id' })
  rescueMenu: RescueMenuOrmEntity;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: () => '1.00' })
  quantity: number;

  @Column({ name: 'unit_price', type: 'decimal', precision: 10, scale: 2, default: () => '0.00' })
  unitPrice: number;

  @Column({ name: 'line_total', type: 'decimal', precision: 10, scale: 2, default: () => '0.00' })
  lineTotal: number;

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