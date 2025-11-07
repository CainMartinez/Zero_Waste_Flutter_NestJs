import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProfileOrmEntity } from './infrastructure/typeorm/entities-orm/profile.orm-entity';
import { ProfileController } from './presentation/controllers/profile.controller';
import { GetProfileUseCase } from './application/use_cases/get-profile.usecase';
import { UpdateProfileUseCase } from './application/use_cases/update-profile.usecase';
import { ProfilesTypeOrmRepository } from './infrastructure/typeorm/repositories/profile.typeorm.repository';
import { IProfilesRepository } from './domain/repositories/profile.repository';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([ProfileOrmEntity]),
    AuthModule,
  ],
  controllers: [ProfileController],
  providers: [
    GetProfileUseCase,
    UpdateProfileUseCase,
    ProfilesTypeOrmRepository,
    {
      provide: IProfilesRepository,
      useExisting: ProfilesTypeOrmRepository,
    },
  ],
})
export class ProfileModule {}