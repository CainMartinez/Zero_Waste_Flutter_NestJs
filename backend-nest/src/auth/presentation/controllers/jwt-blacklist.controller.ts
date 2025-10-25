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

/**
 * Controlador para cerrar sesión de un usuario autenticado.
 * - El token de acceso usado se revoca y se añade a la blacklist.
 * - El refresh token activo del usuario también se revoca.
 */
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
    const token = req.headers.authorization?.replace('Bearer ', '');
    const { jti, sub, exp } = req.user;
    await this.logoutUseCase.execute({
      jti,
      userId: Number(sub),
      token,
      exp,
    });
  }
}