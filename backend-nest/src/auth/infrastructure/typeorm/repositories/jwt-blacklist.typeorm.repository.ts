import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { LessThanOrEqual, MoreThan, Repository } from 'typeorm';

import { JwtBlacklistOrmEntity } from '../entities-orm/blacklist.orm-entity';
import { IJwtBlacklistRepository } from '../../../domain/repositories/jwt-blacklist.repository';
import { JwtBlacklistEntry } from '../../../domain/entities/blacklist.entity';

@Injectable()
export class JwtBlacklistTypeOrmRepository implements IJwtBlacklistRepository {
  constructor(
    @InjectRepository(JwtBlacklistOrmEntity)
    private readonly repo: Repository<JwtBlacklistOrmEntity>,
  ) {}

  /**
   * Inserta una entrada en la blacklist. Debe ser idempotente para el mismo JTI.
   * Usa INSERT ... ON DUPLICATE KEY IGNORE a través de QueryBuilder.
   */
  async add(entry: JwtBlacklistEntry): Promise<void> {
    const orm = this.toOrm(entry);

    await this.repo
      .createQueryBuilder()
      .insert()
      .into(JwtBlacklistOrmEntity)
      .values(orm)
      .orIgnore() // MariaDB/MySQL: ignora si ya existe el mismo PK (jti)
      .execute();
  }

  /**
   * Devuelve true si el JTI está revocado y la entrada aún no ha expirado.
   */
  async isRevoked(jti: string): Promise<boolean> {
    const now = new Date();
    const exists = await this.repo.exists({
      where: { jti, expiresAt: MoreThan(now) },
    });
    return !!exists;
  }

  /**
   * Elimina (o marca para GC) entradas expiradas para contener el tamaño de la tabla.
   * Aquí hacemos borrado físico de expirados por simplicidad.
   * Devuelve el número de filas afectadas.
   */
  async purgeExpired(now: Date = new Date()): Promise<number> {
    const res = await this.repo.delete({ expiresAt: LessThanOrEqual(now) });
    return res.affected ?? 0;
  }

  // ===== Mapeo Domain <-> ORM =====
  private toOrm(d: JwtBlacklistEntry): JwtBlacklistOrmEntity {
    const orm = new JwtBlacklistOrmEntity();
    orm.jti = d.jti;
    orm.userId = d.userId;
    orm.token = d.token ?? null;
    orm.issuedAt = d.issuedAt;
    orm.expiresAt = d.expiresAt;
    orm.revokedAt = d.revokedAt;
    orm.reason = d.reason ?? null;
    return orm;
  }

  private toDomain(o: JwtBlacklistOrmEntity): JwtBlacklistEntry {
    return new JwtBlacklistEntry({
      jti: o.jti,
      userId: o.userId,
      token: o.token ?? null,
      issuedAt: o.issuedAt,
      expiresAt: o.expiresAt,
      revokedAt: o.revokedAt,
      reason: o.reason ?? null,
    });
  }
}