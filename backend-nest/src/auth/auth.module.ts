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

@Module({
  imports: [TypeOrmModule.forFeature([UsersOrmEntity, AdminsOrmEntity, RefreshTokenOrmEntity]),
    JwtModule.register({
      secret: process.env.JWT_SECRET ?? 'dev-secret-change-me',
      signOptions: {
        issuer: process.env.JWT_ISSUER ?? 'zero-waste-api',
        audience: process.env.JWT_AUDIENCE ?? 'zero-waste-clients',
      },
    }),
  ],
  controllers: [RegisterController, LoginController, RefreshController],
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
    {
      provide: IRefreshTokensRepository,
      useExisting: RefreshTokenTypeOrmRepository,
    },
    {
      provide: IUsersRepository,
      useExisting: UsersTypeOrmRepository,
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
  ],
})
export class AuthModule {}