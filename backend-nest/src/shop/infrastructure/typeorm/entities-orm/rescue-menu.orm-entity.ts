import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { ProductOrmEntity } from './product.orm-entity';

@Entity({ name: 'rescue_menus' })
export class RescueMenuOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'char', length: 36, nullable: true, unique: true })
  uuid: string | null;

  @Column({ name: 'name_es', type: 'varchar', length: 190, nullable: true })
  nameEs: string | null;

  @Column({ name: 'name_en', type: 'varchar', length: 190, nullable: true })
  nameEn: string | null;

  @Column({ name: 'description_es', type: 'text', nullable: true })
  descriptionEs: string | null;

  @Column({ name: 'description_en', type: 'text', nullable: true })
  descriptionEn: string | null;

  // --- Composición del menú (FK a products) ---
  @ManyToOne(() => ProductOrmEntity, { eager: false })
  @JoinColumn({ name: 'drink_id' })
  drink: ProductOrmEntity;

  @Column({ name: 'drink_id', type: 'int' })
  drinkId: number;

  @ManyToOne(() => ProductOrmEntity, { eager: false })
  @JoinColumn({ name: 'starter_id' })
  starter: ProductOrmEntity;

  @Column({ name: 'starter_id', type: 'int' })
  starterId: number;

  @ManyToOne(() => ProductOrmEntity, { eager: false })
  @JoinColumn({ name: 'main_id' })
  main: ProductOrmEntity;

  @Column({ name: 'main_id', type: 'int' })
  mainId: number;

  @ManyToOne(() => ProductOrmEntity, { eager: false })
  @JoinColumn({ name: 'dessert_id' })
  dessert: ProductOrmEntity;

  @Column({ name: 'dessert_id', type: 'int' })
  dessertId: number;

  // --- Precio / flags ---
  @Column({ type: 'decimal', precision: 10, scale: 2, default: () => '0.00' })
  price: number;

  @Column({ type: 'varchar', length: 3, default: () => "'EUR'" })
  currency: string;

  @Column({ 
    name: 'is_vegan', 
    type: 'tinyint', 
    width: 1, 
    default: () => '0',
    transformer: {
      to: (value: boolean): number => value ? 1 : 0,
      from: (value: number): boolean => Boolean(value)
    }
  })
  isVegan: boolean;

  @Column({ 
    name: 'is_active', 
    type: 'tinyint', 
    width: 1, 
    default: () => '1',
    transformer: {
      to: (value: boolean): number => value ? 1 : 0,
      from: (value: number): boolean => Boolean(value)
    }
  })
  isActive: boolean;

  // --- Timestamps ---
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