import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersOrmEntity } from './infrastructure/typeorm/entities-orm/users.orm-entity';
import { AdminsOrmEntity } from './infrastructure/typeorm/entities-orm/admins.orm-entity';
import { RegisterUserUseCase } from './application/use_cases/register-user.usecase';
import { UsersTypeOrmRepository } from './infrastructure/typeorm/repositories/users.typeorm.repository';
import { PasswordHasherService } from './infrastructure/crypto/password-hasher.service';
import { IUsersRepository } from './domain/repositories/users.repository';
import { RegisterController } from './presentation/controllers/register.controller';
import { UserPublicAssembler } from './presentation/assemblers/user-public.assembler';
import { JwtModule } from '@nestjs/jwt';
import { LoginUseCase } from './application/use_cases/login.usecase';
import { JwtTokenService } from './infrastructure/token/jwt-token.service';
import { LoginController } from './presentation/controllers/login.controller';
import { RefreshController } from './presentation/controllers/refresh-token.controller';
import { JwtStrategy } from './infrastructure/strategies/jwt.strategy';
import { RefreshAccessTokenUseCase } from './application/use_cases/refresh-access-token.usecase';
import { JwtBlacklistOrmEntity } from './infrastructure/typeorm/entities-orm/blacklist.orm-entity';
import { JwtBlacklistTypeOrmRepository } from './infrastructure/typeorm/repositories/jwt-blacklist.typeorm.repository';
import { IJwtBlacklistRepository } from './domain/repositories/jwt-blacklist.repository';
import { LogoutController } from './presentation/controllers/jwt-blacklist.controller';
import { LogoutUseCase } from './application/use_cases/logout.usecase';
import { AdminLoginController } from './presentation/controllers/admin-login.controller';
import { AdminLoginUseCase } from './application/use_cases/admin-login.usecase';
import { AdminsTypeOrmRepository } from './infrastructure/typeorm/repositories/admin.typeorm.repository';
import { IAdminsRepository } from './domain/repositories/admin.repository';
import { AdminPublicAssembler } from './presentation/assemblers/admin-public.assembler';
import { AdminLogoutController } from './presentation/controllers/admin-logout.controller';
import { AdminLogoutUseCase } from './application/use_cases/admin-logout.usecase';
import { ChangePasswordController } from './presentation/controllers/change-password.controller';
import { ChangePasswordUseCase } from './application/use_cases/change-password.usecase';

@Module({
  imports: [TypeOrmModule.forFeature([UsersOrmEntity, AdminsOrmEntity, JwtBlacklistOrmEntity]),
    JwtModule.register({
      secret: process.env.JWT_SECRET ?? 'dev-secret-change-me',
      signOptions: {
        issuer: process.env.JWT_ISSUER ?? 'zero-waste-api',
        audience: process.env.JWT_AUDIENCE ?? 'zero-waste-clients',
      },
    }),
  ],
  controllers: [RegisterController, LoginController, RefreshController, LogoutController, AdminLoginController, AdminLogoutController, ChangePasswordController],
  providers: [
    RegisterUserUseCase,
    PasswordHasherService,
    UserPublicAssembler,
    UsersTypeOrmRepository,
    LoginUseCase,
    JwtTokenService,
    RefreshAccessTokenUseCase,
    JwtStrategy,
    JwtBlacklistTypeOrmRepository,
    LogoutUseCase,
    AdminLoginUseCase,
    AdminsTypeOrmRepository,
    AdminPublicAssembler,
    AdminLogoutUseCase,
    ChangePasswordUseCase,
    {
      provide: IUsersRepository,
      useExisting: UsersTypeOrmRepository,
    },
    {
      provide: IJwtBlacklistRepository,
      useExisting: JwtBlacklistTypeOrmRepository,
    },
    { 
      provide: IAdminsRepository, 
      useExisting: AdminsTypeOrmRepository 
    },
  ],
  exports: [
    RegisterUserUseCase,
    JwtModule,
    JwtTokenService,
    PasswordHasherService,
    RefreshAccessTokenUseCase,
    {
      provide: IUsersRepository,
      useExisting: UsersTypeOrmRepository,
    },
    {
      provide: IJwtBlacklistRepository,
      useExisting: JwtBlacklistTypeOrmRepository,
    },
    { 
      provide: IAdminsRepository, 
      useExisting: AdminsTypeOrmRepository 
    },
  ],
})
export class AuthModule {}