import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersOrmEntity } from './infrastructure/typeorm/entities-orm/users.orm-entity';
import { AdminsOrmEntity } from './infrastructure/typeorm/entities-orm/admins.orm-entity';
import { ProfilesOrmEntity } from './infrastructure/typeorm/entities-orm/profiles.orm-entity';

@Module({
  imports: [TypeOrmModule.forFeature([UsersOrmEntity, AdminsOrmEntity, ProfilesOrmEntity])],
})
export class AuthModule {}
