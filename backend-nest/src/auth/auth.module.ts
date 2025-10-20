import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersOrmEntity } from './infrastructure/typeorm/entities-orm/users.orm-entity';
import { AdminsOrmEntity } from './infrastructure/typeorm/entities-orm/admins.orm-entity';
import { ProfilesOrmEntity } from './infrastructure/typeorm/entities-orm/profiles.orm-entity';
import { RegisterUserUseCase } from './application/use_cases/register-user.usecase';
import { UsersTypeOrmRepository } from './infrastructure/typeorm/repositories/users.typeorm.repository';
import { PasswordHasherService } from './infrastructure/crypto/password-hasher.service';
import { IUsersRepository } from './domain/repositories/users.repository';
import { RegisterController } from './presentation/controllers/register.controller';
import { UserPublicAssembler } from './presentation/assemblers/user-public.assembler';

@Module({
  imports: [TypeOrmModule.forFeature([UsersOrmEntity, AdminsOrmEntity, ProfilesOrmEntity])],
  controllers: [RegisterController],
  providers: [
    RegisterUserUseCase,
    PasswordHasherService,
    UserPublicAssembler,
    UsersTypeOrmRepository,
    {
      provide: IUsersRepository,
      useExisting: UsersTypeOrmRepository,
    },
  ],
  exports: [RegisterUserUseCase],
})
export class AuthModule {}