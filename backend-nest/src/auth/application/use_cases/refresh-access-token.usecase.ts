import { Injectable, Logger } from '@nestjs/common';
import { JwtTokenService } from '../../infrastructure/token/jwt-token.service';
import { IRefreshTokensRepository } from '../../domain/repositories/refresh-token.repository';
import { IUsersRepository } from '../../domain/repositories/users.repository';
import { UserNotFoundException } from '../../domain/exceptions/user-not-found.exception';
import { InvalidRefreshTokenException } from '../../domain/exceptions/invalid-refresh-token.exception';
import { RefreshTokenInactiveException } from '../../domain/exceptions/refresh-token-inactive.exception';

type RefreshResult = {
  accessToken: string;
};

@Injectable()
export class RefreshAccessTokenUseCase {
  private readonly logger = new Logger(RefreshAccessTokenUseCase.name);

  constructor(
    private readonly jwtTokens: JwtTokenService,
    private readonly refreshRepo: IRefreshTokensRepository,
    private readonly usersRepo: IUsersRepository,
  ) {}

  /**
   * Endpoint protegido por access token.
   * - Obtiene userId (sub) y email desde el access validado.
   * - Verifica que el usuario existe y coincide con el subject.
   * - Requiere que el usuario tenga al menos un refresh activo en whitelist.
   * - Emite un nuevo access token (TTL corto).
   */
  async executeForUser(userId: number, email?: string): Promise<RefreshResult> {
    if (!email || typeof email !== 'string') {
      throw new InvalidRefreshTokenException('No se pudo determinar el usuario del token de acceso.');
    }

    const user = await this.usersRepo.findByEmail(email.toLowerCase());
    if (!user || !user.isActive || user.id !== Number(userId)) {
      throw new UserNotFoundException(email);
    }

    // Debe existir al menos un refresh activo asociado al usuario.
    const hasActive = await this.refreshRepo.hasActiveForUser(user.id);
    if (!hasActive) {
      throw new RefreshTokenInactiveException(`USER:${user.id}`);
    }

    const { token: accessToken } = await this.jwtTokens.signAccessToken(user);
    this.logger.log(`Access renovado (via access JWT) para ${user.email}`);
    return { accessToken };
  }
}