import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfileOrmEntity } from './infrastructure/typeorm/entities-orm/profile.orm-entity';

@Module({
  imports: [TypeOrmModule.forFeature([ProfileOrmEntity])],
})
export class ProfileModule {}