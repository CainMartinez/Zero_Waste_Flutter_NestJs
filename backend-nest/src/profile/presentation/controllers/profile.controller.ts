import { Body, Controller, Get, Patch, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOkResponse, ApiOperation, ApiTags, ApiUnauthorizedResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../../auth/presentation/guards/jwt-auth.guard';
import { GetProfileUseCase } from '../../application/use_cases/get-profile.usecase';
import { UpdateProfileUseCase } from '../../application/use_cases/update-profile.usecase';
import { ProfileResponseDto } from '../../application/dto/response/profile.response.dto';
import { UpdateProfileRequestDto } from '../../application/dto/request/update-profile.request.dto';

@ApiTags('Profile')
@ApiBearerAuth()
@Controller('profile')
export class ProfileController {
  constructor(
    private readonly getProfile: GetProfileUseCase,
    private readonly updateProfile: UpdateProfileUseCase,
  ) {}

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Obtener el perfil del usuario/admin autenticado' })
  @ApiOkResponse({ description: 'Perfil encontrado', type: ProfileResponseDto })
  @ApiUnauthorizedResponse({ description: 'Token inválido o revocado' })
  async me(@Req() req: any): Promise<ProfileResponseDto> {
    const email: string = req.user?.email;
    const ownerType: 'user' | 'admin' = req.user?.ownerType || 'user';

    return this.getProfile.execute(ownerType, email);
  }

  @Patch('update')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Actualizar el perfil del usuario/admin autenticado' })
  @ApiOkResponse({ description: 'Perfil actualizado correctamente', type: ProfileResponseDto })
  @ApiUnauthorizedResponse({ description: 'Token inválido o revocado' })
  async updateMe(@Req() req: any, @Body() dto: UpdateProfileRequestDto): Promise<ProfileResponseDto> {
    const email: string = req.user?.email;
    const ownerType: 'user' | 'admin' = req.user?.ownerType || 'user';

    return this.updateProfile.execute(ownerType, email, dto);
  }
}