import { Column, Entity, JoinColumn, ManyToOne, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { CategoryOrmEntity } from './category.orm-entity';
import { ImageOrmEntity } from '../../../../media/infrastructure/typeorm/entities-orm/image.orm-entity';
import { ProductAllergenOrmEntity } from './product-allergen.orm-entity';

@Entity({ name: 'products' })
export class ProductOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'char', length: 36, unique: true })
  uuid: string;

  @Column({ name: 'name_es', type: 'varchar', length: 190 })
  nameEs: string;

  @Column({ name: 'name_en', type: 'varchar', length: 190 })
  nameEn: string;

  @Column({ name: 'description_es', type: 'text' })
  descriptionEs: string;

  @Column({ name: 'description_en', type: 'text' })
  descriptionEn: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
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

  @ManyToOne(() => CategoryOrmEntity, (category) => category.products, { eager: false })
  @JoinColumn({ name: 'category_id' })
  category: CategoryOrmEntity;

  @OneToMany(() => ImageOrmEntity, (image) => image.product, { eager: false })
  images: ImageOrmEntity[];

  @OneToMany(() => ProductAllergenOrmEntity, (pa) => pa.product, { eager: false })
  allergens: ProductAllergenOrmEntity[];

  @Column({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @Column({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;
}
