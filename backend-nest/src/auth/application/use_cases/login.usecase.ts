import { Injectable, Logger } from '@nestjs/common';
import { IUsersRepository } from '../../domain/repositories/users.repository';
import { PasswordHasherService } from '../../infrastructure/crypto/password-hasher.service';
import { JwtTokenService } from '../../infrastructure/token/jwt-token.service';
import { LoginRequestDto } from '../dto/request/login.request.dto';
import { UserNotFoundException } from '../../domain/exceptions/user-not-found.exception';
import { InvalidPasswordException } from '../../domain/exceptions/invalid-password.exception';
import { User } from '../../domain/entities/users.entity';
import { IRefreshTokensRepository } from '../../domain/repositories/refresh-token.repository';
import { RefreshToken } from '../../domain/entities/refresh-token.entity';

type LoginResult = {
  accessToken: string;
  user: User;
};

@Injectable()
export class LoginUseCase {
  private readonly logger = new Logger(LoginUseCase.name);

  constructor(
    private readonly usersRepository: IUsersRepository,
    private readonly passwordHasher: PasswordHasherService,
    private readonly jwtTokens: JwtTokenService,
    private readonly refreshRepo: IRefreshTokensRepository,
  ) {}

  async execute(dto: LoginRequestDto): Promise<LoginResult> {
    const email = dto.email.trim().toLowerCase();

    const user = await this.usersRepository.findByEmail(email);
    if (!user) {
      throw new UserNotFoundException(email);
    }

    const isValid = await this.passwordHasher.verify(user.passwordHash, dto.password);
    if (!isValid) {
      throw new InvalidPasswordException();
    }

    const { token: accessToken } = await this.jwtTokens.signAccessToken(user);

    const { jti, exp } = await this.jwtTokens.signRefreshToken(user);
    const refresh = new RefreshToken({
      userId: user.id,
      jti,
      expiresAt: new Date(exp * 1000),
    });
    await this.refreshRepo.save(refresh);

    this.logger.log(`Login correcto: ${user.email} (refresh guardado: ${jti})`);
    return { accessToken, user };
  }
}