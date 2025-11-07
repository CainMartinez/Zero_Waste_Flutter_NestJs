import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
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
import { LogoutRequestDto } from '../../application/dto/request/logout.request.dto';

/**
 * Controlador para cerrar sesión de un usuario autenticado.
 * - El token de acceso usado se revoca y se añade a la blacklist.
 * - Opcionalmente se puede enviar el refresh token en el body para revocarlo también.
 */
@ApiTags('Auth')
@ApiBearerAuth()
@Controller('auth')
export class LogoutController {
  constructor(private readonly logoutUseCase: LogoutUseCase) {}

  /**
   * POST /auth/logout
   *
   * Revoca el access token actual añadiéndolo a la blacklist.
   * Opcionalmente revoca el refresh token si se envía en el body.
   */
  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { ttl: 60, limit: 10 } })
  @ApiOperation({ summary: 'Cerrar sesión del usuario' })
  @ApiNoContentResponse({ description: 'Logout realizado correctamente' })
  @ApiUnauthorizedResponse({ description: 'Token de acceso inválido o caducado' })
  async logout(@Req() req: any, @Body() dto: LogoutRequestDto): Promise<void> {
    const token = req.headers.authorization?.replace('Bearer ', '');
    const { jti, sub, exp } = req.user;
    await this.logoutUseCase.execute({
      jti,
      userId: Number(sub),
      token,
      exp,
      refreshToken: dto.refreshToken,
    });
  }
}