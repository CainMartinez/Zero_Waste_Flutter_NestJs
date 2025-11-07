import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { IAdminsRepository } from '../../../domain/repositories/admin.repository';
import { AdminsOrmEntity } from '../entities-orm/admins.orm-entity';
import { Admin } from '../../../domain/entities/admins.entity';

@Injectable()
export class AdminsTypeOrmRepository implements IAdminsRepository {
  constructor(
    @InjectRepository(AdminsOrmEntity)
    private readonly repo: Repository<AdminsOrmEntity>,
  ) {}

  async findByEmail(email: string): Promise<Admin | null> {
    const found = await this.repo.findOne({ where: { email } });
    return found ? this.toDomain(found) : null;
  }

  async updateAdmin(admin: Admin): Promise<Admin> {
    const orm = await this.repo.findOne({ where: { id: admin.id } });
    if (!orm) {
      throw new Error(`Admin with id ${admin.id} not found`);
    }

    orm.name = admin.name;
    orm.passwordHash = admin.passwordHash;
    orm.avatarUrl = admin.avatarUrl;
    orm.isActive = admin.isActive;
    orm.updatedAt = new Date();

    const saved = await this.repo.save(orm);
    return this.toDomain(saved);
  }

  private toDomain(orm: AdminsOrmEntity): Admin {
    return new Admin({
      id: orm.id,
      uuid: orm.uuid,
      email: orm.email,
      name: orm.name,
      passwordHash: orm.passwordHash,
      avatarUrl: orm.avatarUrl,
      isActive: orm.isActive,
      createdAt: orm.createdAt,
      updatedAt: orm.updatedAt,
    });
  }
}