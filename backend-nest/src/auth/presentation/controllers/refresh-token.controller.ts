import { Controller, Post, Req, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { RefreshAccessResponseDto } from '../../application/dto/response/refresh-token.response.dto';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { RefreshAccessTokenUseCase } from '../../application/use_cases/refresh-access-token.usecase';

/**
 * Controlador de renovación de access token.
 * Protegido por JWT de acceso: los claims `sub` y `email` se leen de req.user.
 */
@ApiTags('Auth')
@ApiBearerAuth()
@Controller('auth')
export class RefreshController {
  constructor(private readonly refreshUseCase: RefreshAccessTokenUseCase) {}

  /**
   * POST /auth/refresh
   *
   * Emite un nuevo access token para el usuario autenticado.
   * Requisitos:
   *  - El access token del request debe ser válido (no expirado) para poder llegar aquí.
   *  - Debe existir un refresh activo asociado a este usuario en la whitelist.
   */
  @Post('refresh')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { ttl: 60, limit: 10 } })
  @ApiOperation({
    summary: 'Renovar access token usando sesión del usuario',
    description:
      'Obtiene userId (sub) y email del JWT de acceso y valida que exista un refresh activo asociado. Devuelve un nuevo access token.',
  })
  @ApiOkResponse({
    description: 'Access token renovado correctamente',
    type: RefreshAccessResponseDto,
  })
  @ApiUnauthorizedResponse({
    description:
      'Token de acceso inválido o no autorizado, o no existe un refresh activo para el usuario.',
  })
  async refresh(@Req() req: any): Promise<RefreshAccessResponseDto> {
    // `req.user` es rellenado por la JwtStrategy al validar el access token
    const userId: number = Number(req.user?.sub);
    const email: string | undefined = req.user?.email;

    const { accessToken } = await this.refreshUseCase.executeForUser(userId, email);
    return { accessToken };
  }
}