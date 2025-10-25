import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

import { IUsersRepository } from '../../../domain/repositories/users.repository';
import { User } from '../../../domain/entities/users.entity';
import { EmailAlreadyInUseException } from '../../../domain/exceptions/email-already-in-use.exception';

import { UsersOrmEntity } from '../entities-orm/users.orm-entity';

@Injectable()
export class UsersTypeOrmRepository extends IUsersRepository {
  constructor(
    @InjectRepository(UsersOrmEntity)
    private readonly repo: Repository<UsersOrmEntity>,
  ) {
    super();
  }

  async existsByEmail(email: string): Promise<boolean> {
    return this.repo.exist({ where: { email } });
  }

  async findByEmail(email: string): Promise<User | null> {
    const orm = await this.repo.findOne({ where: { email } });
    return orm ? this.mapOrmToDomain(orm) : null;
  }
  
  async createUser(user: User): Promise<User> {
    try {
      const toSave = this.repo.create({
        uuid: user.uuid ?? null,
        email: user.email,
        name: user.name,
        passwordHash: user.passwordHash, // columna: password_hash
        avatarUrl: user.avatarUrl ?? null,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      });

      const saved = await this.repo.save(toSave);
      return this.mapOrmToDomain(saved);
    } catch (err: any) {
      // MariaDB/MySQL duplicate key
      if (err?.code === 'ER_DUP_ENTRY') {
        throw new EmailAlreadyInUseException(user.email);
      }
      throw err;
    }
  }

  // ---------- helpers ----------
  private mapOrmToDomain(orm: UsersOrmEntity): User {
    return new User({
      id: orm.id,
      uuid: orm.uuid,
      email: orm.email,
      name: orm.name,
      passwordHash: orm.passwordHash,
      avatarUrl: orm.avatarUrl,
      isActive: !!orm.isActive,
      createdAt: orm.createdAt,
      updatedAt: orm.updatedAt,
    });
  }
}