import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Index,
} from 'typeorm';
import { UsersOrmEntity } from '../../../../auth/infrastructure/typeorm/entities-orm/users.orm-entity';
import { LoyaltyRuleOrmEntity } from './loyalty-rule.orm-entity';
import { RescueMenuOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/rescue-menu.orm-entity';
import { OrderOrmEntity } from '../../../../orders/infrastructure/typeorm/entities-orm/order.orm-entity';

@Entity({ name: 'loyalty_redemptions' })
@Index('idx_loyalty_redemptions_user', ['userId'])
export class LoyaltyRedemptionOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', type: 'int' })
  userId: number;

  @ManyToOne(() => UsersOrmEntity, { eager: false })
  @JoinColumn({ name: 'user_id' })
  user: UsersOrmEntity;

  @Column({ name: 'rule_id', type: 'int' })
  ruleId: number;

  @ManyToOne(() => LoyaltyRuleOrmEntity, { eager: false })
  @JoinColumn({ name: 'rule_id' })
  rule: LoyaltyRuleOrmEntity;

  @Column({ name: 'rescue_menu_id', type: 'int' })
  rescueMenuId: number;

  @ManyToOne(() => RescueMenuOrmEntity, { eager: false })
  @JoinColumn({ name: 'rescue_menu_id' })
  rescueMenu: RescueMenuOrmEntity;

  @Column({ name: 'order_id', type: 'int', nullable: true })
  orderId: number | null;

  @ManyToOne(() => OrderOrmEntity, { eager: false })
  @JoinColumn({ name: 'order_id' })
  order: OrderOrmEntity;

  @Column({ name: 'redeemed_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  redeemedAt: Date;

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