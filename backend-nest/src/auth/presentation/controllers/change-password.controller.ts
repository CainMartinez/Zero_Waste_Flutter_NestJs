import { Body, Controller, Patch, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiNoContentResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { ChangePasswordUseCase } from '../../application/use_cases/change-password.usecase';
import { ChangePasswordRequestDto } from '../../application/dto/request/change-password.request.dto';

@ApiTags('Auth')
@ApiBearerAuth()
@Controller('auth')
export class ChangePasswordController {
  constructor(private readonly changePassword: ChangePasswordUseCase) {}

  @Patch('password')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Cambiar contraseña del usuario autenticado' })
  @ApiNoContentResponse({ description: 'Contraseña actualizada correctamente' })
  @ApiUnauthorizedResponse({ description: 'Token inválido o contraseña actual incorrecta' })
  async change(@Req() req: any, @Body() dto: ChangePasswordRequestDto): Promise<void> {
    const email: string = req.user?.email;
    await this.changePassword.execute(email, dto.currentPassword, dto.newPassword);
  }
}
