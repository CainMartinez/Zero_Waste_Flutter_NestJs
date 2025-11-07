import { Controller, Post, Req, UnauthorizedException } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { RefreshAccessResponseDto } from '../../application/dto/response/refresh-token.response.dto';
import { RefreshAccessTokenUseCase } from '../../application/use_cases/refresh-access-token.usecase';
import { JwtTokenService } from '../../infrastructure/token/jwt-token.service';

/**
 * Controlador de renovación de access token (stateless).
 * Recibe un refresh token válido por Bearer y emite un nuevo access token.
 */
@ApiTags('Auth')
@ApiBearerAuth()
@Controller('auth')
export class RefreshController {
  constructor(
    private readonly refreshUseCase: RefreshAccessTokenUseCase,
    private readonly jwtTokens: JwtTokenService,
  ) {}

  /**
   * POST /auth/refresh
   *
   * Emite un nuevo access token usando un refresh token válido enviado por Bearer.
   * Modo stateless: solo valida el JWT del refresh token.
   */
  @Post('refresh')
  @Throttle({ default: { ttl: 60, limit: 10 } })
  @ApiOperation({
    summary: 'Renovar access token usando refresh token',
    description:
      'Recibe un refresh token válido en el header Authorization: Bearer <refreshToken> y devuelve un nuevo access token. Validación completamente stateless basada en JWT.',
  })
  @ApiOkResponse({
    description: 'Access token renovado correctamente',
    type: RefreshAccessResponseDto,
  })
  @ApiUnauthorizedResponse({
    description: 'Refresh token expirado, inválido o no proporcionado',
  })
  async refresh(@Req() req: any): Promise<RefreshAccessResponseDto> {
    // Extraer el refresh token del header Authorization
    const authHeader: string | undefined = req.headers?.authorization;
    const refreshToken = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : '';

    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token no proporcionado');
    }

    // Verificar y decodificar el refresh token
    const payload = await this.jwtTokens.verify(refreshToken);
    
    const userId: number = Number(payload.sub);
    const email: string = payload.email;
    const ownerType: 'user' | 'admin' = payload.ownerType || 'user';

    // Ejecutar el caso de uso
    const { accessToken } = await this.refreshUseCase.executeForUser(userId, email, ownerType);

    return { accessToken };
  }
}