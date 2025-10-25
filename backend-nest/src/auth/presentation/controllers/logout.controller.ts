import { Controller, Post, Req, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBearerAuth,
  ApiNoContentResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { LogoutUseCase } from '../../application/use_cases/logout.usecase';

@ApiTags('Auth')
@ApiBearerAuth()
@Controller('auth')
export class LogoutController {
  constructor(private readonly logoutUseCase: LogoutUseCase) {}

  /**
   * POST /auth/logout
   *
   * Revoca el access token actual (añadiéndolo a la blacklist)
   * y los refresh tokens activos del usuario.
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { ttl: 60, limit: 10 } })
  @ApiOperation({ summary: 'Cerrar sesión del usuario' })
  @ApiNoContentResponse({ description: 'Logout realizado correctamente' })
  @ApiUnauthorizedResponse({ description: 'Token de acceso inválido o caducado' })
  async logout(@Req() req: any): Promise<void> {
    const authHeader: string | undefined = req.headers?.authorization;
    const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : '';

    // req.user viene de JwtStrategy.validate()
    const jti: string | undefined = req.user?.jti;
    const sub: string | number | undefined = req.user?.sub;
    const exp: number | undefined = req.user?.exp ?? req.user?.expiresAt;

    await this.logoutUseCase.execute({
      jti: String(jti),
      userId: Number(sub),
      token,
      exp: Number(exp),
    });
    return;
  }
}