import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, MoreThan, Repository } from 'typeorm';
import { RefreshTokenOrmEntity } from '../entities-orm/refresh-token.orm-entity';
import { RefreshToken } from '../../../domain/entities/refresh-token.entity';

@Injectable()
export class RefreshTokenTypeOrmRepository {
  constructor(
    @InjectRepository(RefreshTokenOrmEntity)
    private readonly repo: Repository<RefreshTokenOrmEntity>,
  ) {}

  /**
   * Guarda un nuevo refresh token emitido.
   * Si ya existe un registro con el mismo JTI, lo sobrescribe.
   */
  async save(token: RefreshToken): Promise<RefreshToken> {
    const ormEntity = this.toOrmEntity(token);
    const saved = await this.repo.save(ormEntity);
    return this.toDomainEntity(saved);
  }

  /**
   * Busca un token por su JTI (identificador único del JWT).
   * Devuelve null si no existe.
   */
  async findByJti(jti: string): Promise<RefreshToken | null> {
    const found = await this.repo.findOne({ where: { jti } });
    return found ? this.toDomainEntity(found) : null;
  }

  /**
   * Marca un token como revocado. No lo elimina físicamente.
   */
  async revokeByJti(jti: string, reason: string = 'logout'): Promise<void> {
    await this.repo.update(
      { jti },
      { revokedAt: new Date(), reason },
    );
  }

  /**
   * Verifica si un token individual está activo.
   */
  async isActive(jti: string): Promise<boolean> {
    const token = await this.repo.findOne({ where: { jti } });
    if (!token) return false;
    return !token.revokedAt && token.expiresAt > new Date();
  }

  /**
   * Indica si el usuario tiene al menos un refresh token activo.
   * Se usa para validar sesiones en /auth/refresh.
   */
  async hasActiveForUser(userId: number): Promise<boolean> {
    const count = await this.repo.count({
      where: {
        userId,
        revokedAt: IsNull(),
        expiresAt: MoreThan(new Date()),
      },
    });
    return count > 0;
  }

  private toDomainEntity(orm: RefreshTokenOrmEntity): RefreshToken {
    return new RefreshToken({
      id: orm.id,
      userId: orm.userId,
      jti: orm.jti,
      expiresAt: orm.expiresAt,
      createdAt: orm.createdAt,
      revokedAt: orm.revokedAt,
      reason: orm.reason,
    });
  }

  private toOrmEntity(domain: RefreshToken): RefreshTokenOrmEntity {
    const orm = new RefreshTokenOrmEntity();
    orm.id = domain.id ?? undefined!;
    orm.userId = domain.userId;
    orm.jti = domain.jti;
    orm.expiresAt = domain.expiresAt;
    orm.createdAt = domain.createdAt;
    orm.revokedAt = domain.revokedAt;
    orm.reason = domain.reason;
    return orm;
  }
}