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
import { RefreshTokenOrmEntity } from './infrastructure/typeorm/entities-orm/refresh-token.orm-entity';
import { RefreshTokenTypeOrmRepository } from './infrastructure/typeorm/repositories/refresh-token.typeorm.repository';
import { IRefreshTokensRepository } from './domain/repositories/refresh-token.repository';
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

@Module({
  imports: [TypeOrmModule.forFeature([UsersOrmEntity, AdminsOrmEntity, RefreshTokenOrmEntity, JwtBlacklistOrmEntity]),
    JwtModule.register({
      secret: process.env.JWT_SECRET ?? 'dev-secret-change-me',
      signOptions: {
        issuer: process.env.JWT_ISSUER ?? 'zero-waste-api',
        audience: process.env.JWT_AUDIENCE ?? 'zero-waste-clients',
      },
    }),
  ],
  controllers: [RegisterController, LoginController, RefreshController, LogoutController, AdminLoginController],
  providers: [
    RegisterUserUseCase,
    PasswordHasherService,
    UserPublicAssembler,
    UsersTypeOrmRepository,
    LoginUseCase,
    JwtTokenService,
    RefreshAccessTokenUseCase,
    JwtStrategy,
    RefreshTokenTypeOrmRepository,
    JwtBlacklistTypeOrmRepository,
    LogoutUseCase,
    AdminLoginUseCase,
    AdminsTypeOrmRepository,
    AdminPublicAssembler,
    {
      provide: IRefreshTokensRepository,
      useExisting: RefreshTokenTypeOrmRepository,
    },
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
    {
      provide: IRefreshTokensRepository,
      useExisting: RefreshTokenTypeOrmRepository,
    },
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