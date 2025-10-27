import { Body, Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBadRequestResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { AdminLoginUseCase } from '../../application/use_cases/admin-login.usecase';
import { AdminLoginRequestDto } from '../../application/dto/request/admin-login.request.dto';
import { AdminLoginResponseDto } from '../../application/dto/response/admin-login.response.dto';
import { AdminPublicAssembler } from '../assemblers/admin-public.assembler';

@ApiTags('Admin Auth')
@Controller('auth/admin')
export class AdminLoginController {
  constructor(
    private readonly loginUseCase: AdminLoginUseCase,
    private readonly assembler: AdminPublicAssembler,
  ) {}

  @Post('login')
  @Throttle({ default: { ttl: 60, limit: 5 } })
  @ApiOperation({
    summary: 'Inicio de sesión de administrador',
    description: 'Autentica un administrador y devuelve access token + datos públicos.',
  })
  @ApiOkResponse({ description: 'Inicio de sesión correcto', type: AdminLoginResponseDto })
  @ApiBadRequestResponse({ description: 'Payload inválido o incompleto' })
  @ApiUnauthorizedResponse({ description: 'Credenciales incorrectas o admin inactivo' })
  async login(@Body() dto: AdminLoginRequestDto): Promise<AdminLoginResponseDto> {
    const { admin, accessToken } = await this.loginUseCase.execute(dto);
    return this.assembler.toDto(admin, accessToken);
  }
}