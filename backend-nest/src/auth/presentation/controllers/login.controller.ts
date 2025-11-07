import { Body, Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBadRequestResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';

import { LoginUseCase } from '../../application/use_cases/login.usecase';
import { LoginRequestDto } from '../../application/dto/request/login.request.dto';
import { LoginResponseDto } from '../../application/dto/response/login.response.dto';
import { UserPublicAssembler } from '../assemblers/user-public.assembler';

/**
 * Controlador responsable de la autenticación de usuarios.
 * Expone el endpoint `/auth/login` para validar credenciales y emitir tokens JWT.
 */
@ApiTags('Auth')
@Controller('auth')
export class LoginController {
  constructor(
    private readonly loginUseCase: LoginUseCase,
    private readonly assembler: UserPublicAssembler,
  ) {}

  /**
   * Endpoint: **POST /auth/login**
   *
   * Inicia sesión con credenciales válidas (email y contraseña).
   * Si la autenticación es correcta, devuelve un par de tokens JWT
   * (access y refresh) junto con los datos públicos del usuario.
   *
   * Protegido con un **rate limiter** de 5 solicitudes por minuto para
   * mitigar ataques de fuerza bruta o denegación de servicio.
   */
  @Post('login')
  @Throttle({ default: { ttl: 60, limit: 5 } }) // Permite 5 solicitudes cada 60 segundos por IP
  @ApiOperation({
    summary: 'Autenticación de usuario',
    description:
      'Permite iniciar sesión con email y contraseña. Devuelve tokens JWT y la información pública del usuario.',
  })
  @ApiOkResponse({
    description: 'Inicio de sesión correcto',
    type: LoginResponseDto,
  })
  @ApiBadRequestResponse({
    description: 'El payload de entrada es inválido o incompleto',
  })
  @ApiUnauthorizedResponse({
    description: 'Email no registrado o contraseña incorrecta',
  })
  async login(
    @Body() dto: LoginRequestDto,
  ): Promise<LoginResponseDto> {
    // Se delega la lógica de negocio al caso de uso
    const { user, accessToken, refreshToken } = await this.loginUseCase.execute(dto);
    // El assembler transforma la entidad de dominio a DTO público
    return {
      accessToken,
      refreshToken,
      user: this.assembler.toDto(user),
    };
  }
}