import { Injectable, Logger } from '@nestjs/common';
import { IJwtBlacklistRepository } from '../../domain/repositories/jwt-blacklist.repository';
import { IRefreshTokensRepository } from '../../domain/repositories/refresh-token.repository';
import { JwtBlacklistEntry } from '../../domain/entities/blacklist.entity';

/**
 * Caso de uso: Logout del usuario autenticado.
 * - Revoca el access token actual añadiéndolo a la blacklist.
 * - Revoca también el refresh token activo del usuario, si existe.
 */
@Injectable()
export class LogoutUseCase {
  private readonly logger = new Logger(LogoutUseCase.name);

  constructor(
    private readonly blacklistRepo: IJwtBlacklistRepository,
    private readonly refreshRepo: IRefreshTokensRepository,
  ) {}

  /**
   * Ejecuta el proceso de logout.
   * @param params datos extraídos del access token
   */
  async execute(params: {
    jti: string;
    userId: number;
    token: string;
    exp: number;
  }): Promise<void> {
    const expiresAt = new Date(params.exp * 1000);

    // Añadir a la blacklist
    const entry = new JwtBlacklistEntry({
      jti: params.jti,
      userId: params.userId,
      token: params.token,
      issuedAt: new Date(),
      expiresAt,
      revokedAt: new Date(),
      reason: 'logout',
    });

    await this.blacklistRepo.add(entry);

    // Revocar refresh tokens asociados al usuario
    const hasActive = await this.refreshRepo.hasActiveForUser(params.userId);
    if (hasActive) {
      await this.refreshRepo.revokeActiveForUser(params.userId, 'logout');
    }

    this.logger.log(`Logout completado para userId=${params.userId}`);
  }
}