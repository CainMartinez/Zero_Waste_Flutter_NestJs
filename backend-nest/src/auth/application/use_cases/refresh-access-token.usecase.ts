import { Injectable, Logger } from '@nestjs/common';
import { JwtTokenService } from '../../infrastructure/token/jwt-token.service';
import { IRefreshTokensRepository } from '../../domain/repositories/refresh-token.repository';
import { IUsersRepository } from '../../domain/repositories/users.repository';
import { UserNotFoundException } from '../../domain/exceptions/user-not-found.exception';
import { InvalidRefreshTokenException } from '../../domain/exceptions/invalid-refresh-token.exception';
import { RefreshTokenInactiveException } from '../../domain/exceptions/refresh-token-inactive.exception';
import { JwtBlacklistEntry } from '../../domain/entities/blacklist.entity';
import { IJwtBlacklistRepository } from 'src/auth/domain/repositories/jwt-blacklist.repository';

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
    private readonly blacklistRepo: IJwtBlacklistRepository, 
  ) {}

  /**
   * Endpoint protegido por access token.
   * - Obtiene userId (sub) y email desde el access validado.
   * - Verifica que el usuario existe y coincide con el subject.
   * - Requiere que el usuario tenga al menos un refresh activo en whitelist.
   * - Emite un nuevo access token (TTL corto).
   * - El access token original se lleva a la blacklist.
   */
  async executeForUser(userId: number, email?: string, currentAccess?: { jti: string; token: string; exp: number },
): Promise<RefreshResult> {
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

    if (currentAccess?.jti && currentAccess?.token && typeof currentAccess.exp === 'number') {
      const entry = new JwtBlacklistEntry({
        jti: currentAccess.jti,
        userId: user.id,
        token: currentAccess.token,
        issuedAt: new Date(), // marca de registro de la revocación
        expiresAt: new Date(currentAccess.exp * 1000),
        revokedAt: new Date(),
        reason: 'rotated_by_refresh',
      });
      await this.blacklistRepo.add(entry);
      this.logger.log(`Access rotado y añadido a blacklist (jti=${currentAccess.jti}) para ${user.email}`);
    }

    this.logger.log(`Access renovado (via access JWT) para ${user.email}`);
    return { accessToken };
  }
}