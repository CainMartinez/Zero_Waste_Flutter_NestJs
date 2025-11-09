import { 
  Column, 
  Entity, 
  PrimaryGeneratedColumn, 
  CreateDateColumn, 
  UpdateDateColumn, 
  Index,
  ManyToOne,
  JoinColumn
} from 'typeorm';
import { ProductOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/product.orm-entity';
import { RescueMenuOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/rescue-menu.orm-entity';

@Entity({ name: 'images' })
export class ImageOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar', length: 255, unique: true })
  @Index()
  slug: string; // Formato: {bucket}-{timestamp}-{nombre}

  @Column({ name: 'file_name', type: 'varchar', length: 255 })
  fileName: string;

  @Column({ type: 'varchar', length: 500 })
  path: string; // Ruta relativa: /images/products/file.jpg

  @Column({ name: 'mime_type', type: 'varchar', length: 100 })
  mimeType: string;

  @Column({ type: 'int', unsigned: true })
  size: number;

  // Relación con Product (nullable)
  @ManyToOne(() => ProductOrmEntity, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'product_id' })
  product?: ProductOrmEntity;

  @Column({ name: 'product_id', type: 'int', nullable: true })
  @Index()
  productId?: number;

  // Relación con RescueMenu (nullable)
  @ManyToOne(() => RescueMenuOrmEntity, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'menu_id' })
  menu?: RescueMenuOrmEntity;

  @Column({ name: 'menu_id', type: 'int', nullable: true })
  @Index()
  menuId?: number;

  @Column({ name: 'is_active', type: 'tinyint', width: 1, default: 1 })
  isActive: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;
}
