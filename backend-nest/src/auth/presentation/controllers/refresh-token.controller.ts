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
   *  - El access actual se rota y se añade a la blacklist.
   */
  @Post('refresh')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { ttl: 60, limit: 10 } })
  @ApiOperation({
    summary: 'Renovar access token usando sesión del usuario',
    description:
      'Obtiene userId (sub) y email del JWT de acceso y valida que exista un refresh activo asociado. Devuelve un nuevo access token y añade el actual a la blacklist.',
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
    // Extraer token del encabezado Authorization: Bearer <token>
    const authHeader: string | undefined = req.headers?.authorization;
    const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : '';

    // Claims proporcionados por JwtStrategy.validate()
    const userId: number = Number(req.user?.sub);
    const email: string | undefined = req.user?.email;
    const jti: string | undefined = req.user?.jti;
    const exp: number | undefined = req.user?.exp ?? req.user?.expiresAt;

    // Si la estrategia no incluye exp, lo decodificamos del propio token
    const expiration = exp ?? (() => {
      try {
        const [, payloadB64] = token.split('.');
        const json = Buffer.from(payloadB64, 'base64').toString('utf8');
        return (JSON.parse(json) as { exp?: number }).exp ?? 0;
      } catch {
        return 0;
      }
    })();

    // Ejecutar el caso de uso con rotación controlada del access actual
    const { accessToken } = await this.refreshUseCase.executeForUser(
      userId,
      email,
      { jti: String(jti), token, exp: expiration },
    );

    return { accessToken };
  }
}