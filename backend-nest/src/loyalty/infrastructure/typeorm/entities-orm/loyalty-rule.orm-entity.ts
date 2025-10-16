import { Column, Entity, PrimaryGeneratedColumn, Unique } from 'typeorm';

@Entity({ name: 'loyalty_rules' })
@Unique('UQ_loyalty_rule_code', ['code'])
export class LoyaltyRuleOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'char', length: 36, nullable: true, unique: true })
  uuid: string | null;

  @Column({ type: 'varchar', length: 64 })
  code: string;

  @Column({ name: 'every_n_purchases', type: 'int', default: () => '10' })
  everyNPurchases: number;

  @Column({ name: 'reward_type', type: 'varchar', length: 32, default: () => "'free_menu'" })
  rewardType: string;

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