import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
} from 'typeorm';
import { ProductOrmEntity } from './product.orm-entity';
import { AllergenOrmEntity } from './allergen.orm-entity';

@Entity({ name: 'product_allergen' })
@Unique('uq_product_allergen', ['productId', 'allergenCode'])
export class ProductAllergenOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'product_id', type: 'int' })
  productId: number;

  @ManyToOne(() => ProductOrmEntity, { eager: false })
  @JoinColumn({ name: 'product_id' })
  product: ProductOrmEntity;

  @Column({ name: 'allergen_code', type: 'varchar', length: 50 })
  allergenCode: string;

  @ManyToOne(() => AllergenOrmEntity, { eager: false })
  @JoinColumn({ name: 'allergen_code', referencedColumnName: 'code' })
  allergen: AllergenOrmEntity;

  @Column({ type: 'tinyint', width: 1, default: () => '1' })
  contains: boolean;

  @Column({ name: 'may_contain', type: 'tinyint', width: 1, default: () => '0' })
  mayContain: boolean;

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