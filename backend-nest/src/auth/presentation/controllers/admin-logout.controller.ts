import { Controller, Post, Req, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { AdminLogoutUseCase } from '../../application/use_cases/admin-logout.usecase';

/**
 * Endpoint de logout para administradores.
 * Revoca el access token actual añadiéndolo a la blacklist.
 */
@ApiTags('Admin Auth')
@ApiBearerAuth()
@Controller('auth/admin')
export class AdminLogoutController {
  constructor(private readonly logoutUseCase: AdminLogoutUseCase) {}

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @Throttle({ default: { ttl: 60, limit: 5 } })
  @ApiOperation({ summary: 'Cerrar sesión del administrador' })
  @ApiOkResponse({
    description: 'Logout realizado correctamente',
    schema: {
      type: 'object',
      properties: {
        message: { type: 'string', example: 'Logout de administrador correcto' },
      },
    },
  })
  @ApiUnauthorizedResponse({
    description: 'Token inválido, caducado o ya revocado',
  })
  async logout(@Req() req: any): Promise<{ message: string }> {
    const authHeader: string | undefined = req.headers?.authorization;
    const token = authHeader?.startsWith('Bearer ') ? authHeader.slice(7) : '';
    const sub: number = Number(req.user?.sub);

    await this.logoutUseCase.execute({
      userId: sub,
      token,
    });

    return { message: 'Logout de administrador correcto' };
  }
}