import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'allergens' })
export class AllergenOrmEntity {
  @PrimaryColumn({ type: 'varchar', length: 50 })
  code: string;

  @Column({ name: 'name_es', type: 'varchar', length: 190, nullable: true })
  nameEs: string | null;

  @Column({ name: 'name_en', type: 'varchar', length: 190, nullable: true })
  nameEn: string | null;

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