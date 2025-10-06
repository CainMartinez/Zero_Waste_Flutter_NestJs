import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { ProductOrmEntity } from './product.orm-entity';

@Entity({ name: 'categories' })
export class CategoryOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'char', length: 36, nullable: true })
  uuid: string | null;

  @Column({ type: 'varchar', length: 50, unique: true })
  code: string;

  @Column({ name: 'name_es', type: 'varchar', length: 190, nullable: true })
  nameEs: string | null;

  @Column({ name: 'name_en', type: 'varchar', length: 190, nullable: true })
  nameEn: string | null;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: () => '1' })
  isActive: boolean;

  @Column({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @Column({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;

  @OneToMany(() => ProductOrmEntity, (product) => product.category)
  products: ProductOrmEntity[];
}
