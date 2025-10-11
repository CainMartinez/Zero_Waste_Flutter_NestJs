import { Column, Entity, Index, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'users' })
@Index('UQ_users_email', ['email'], { unique: true })
export class UsersOrmEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'char', length: 36, nullable: true, unique: true })
  uuid: string | null;

  @Column({ type: 'varchar', length: 190 })
  email: string;

  @Column({ type: 'varchar', length: 190 })
  name: string;

  @Column({ name: 'password_hash', type: 'varchar', length: 255 })
  passwordHash: string;

  @Column({ name: 'avatar_url', type: 'varchar', length: 255, nullable: true })
  avatarUrl: string | null;

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