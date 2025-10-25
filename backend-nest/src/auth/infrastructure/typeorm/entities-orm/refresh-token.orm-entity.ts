import { Column, Entity, Index, ManyToOne, PrimaryGeneratedColumn, JoinColumn } from 'typeorm';
import { UsersOrmEntity } from './users.orm-entity';

/**
 * Whitelist de refresh tokens (JWT):
 * - Guardamos el JTI y la caducidad (exp) del refresh emitido.
 * - Revocar = marcar revoked_at (soft revoke).
 */
@Entity({ name: 'refresh_tokens' })
@Index('idx_refresh_tokens_user_id', ['userId'])
@Index('idx_refresh_tokens_jti', ['jti'], { unique: true })
export class RefreshTokenOrmEntity {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ name: 'user_id', type: 'int', nullable: false })
  userId!: number;

  @ManyToOne(() => UsersOrmEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user!: UsersOrmEntity;

  // JTI del refresh JWT (uuid v4)
  @Column({ type: 'char', length: 36, unique: true })
  jti!: string;

  // Fecha/hora de creación (cuando se emitió el refresh)
  @Column({ name: 'created_at', type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt!: Date;

  // Caducidad (epoch seconds o timestamp). Usamos timestamp para compatibilidad SQL.
  @Column({ name: 'expires_at', type: 'timestamp' })
  expiresAt!: Date;

  // Si está revocado, se marca esta fecha. Null = activo.
  @Column({ name: 'revoked_at', type: 'timestamp', nullable: true })
  revokedAt!: Date | null;

  // Motivo opcional de revocación (logout, rotation, compromised…)
  @Column({ type: 'varchar', length: 100, nullable: true })
  reason!: string | null;

  // Metadatos opcionales (dispositivo, ip, agente)
  @Column({ name: 'device_label', type: 'varchar', length: 100, nullable: true })
  deviceLabel!: string | null;

  @Column({ name: 'last_ip', type: 'varchar', length: 45, nullable: true })
  lastIp!: string | null;

  @Column({ name: 'last_user_agent', type: 'varchar', length: 190, nullable: true })
  lastUserAgent!: string | null;
}