import {
  Column,
  Entity,
  Index,
  JoinColumn,
  ManyToOne,
  PrimaryColumn,
} from 'typeorm';
import { UsersOrmEntity } from './users.orm-entity';

@Entity({ name: 'jwt_blacklist' })
@Index('idx_jwt_blacklist_user_id', ['userId'])
@Index('idx_jwt_blacklist_expires_at', ['expiresAt'])
@Index('idx_jwt_blacklist_revoked_at', ['revokedAt'])
export class JwtBlacklistOrmEntity {
  @PrimaryColumn({ name: 'jti', type: 'varchar', length: 255 })
  jti: string;

  @Column({ name: 'user_id', type: 'int' })
  userId: number;

  @ManyToOne(() => UsersOrmEntity, { eager: false })
  @JoinColumn({ name: 'user_id' })
  user: UsersOrmEntity;

  @Column({ name: 'token', type: 'text', nullable: true })
  token: string | null;

  @Column({ name: 'issued_at', type: 'timestamp' })
  issuedAt: Date;

  @Column({ name: 'expires_at', type: 'timestamp' })
  expiresAt: Date;

  @Column({
    name: 'revoked_at',
    type: 'timestamp',
    default: () => 'CURRENT_TIMESTAMP',
  })
  revokedAt: Date;

  @Column({ name: 'reason', type: 'varchar', length: 100, nullable: true })
  reason: string | null;
}