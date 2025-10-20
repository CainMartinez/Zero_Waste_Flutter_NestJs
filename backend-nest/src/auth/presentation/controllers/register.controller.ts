import { Body, Controller, Post } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import {
  ApiBadRequestResponse,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';

import { RegisterUserUseCase } from '../../application/use_cases/register-user.usecase';
import { RegisterUserRequestDto } from '../../application/dto/request/register-user.request.dto';
import { UserPublicResponseDto } from '../../application/dto/response/user-public.response.dto';
import { UserPublicAssembler } from '../assemblers/user-public.assembler';

/**
 * Controlador HTTP: /auth/register
 *
 * Expone el endpoint de registro de usuario.
 * - Aplica limitador de peticiones para prevenir spam/DDOS.
 * - Documentado con Swagger.
 * - Convierte la entidad de dominio a DTO antes de responder.
 */
@ApiTags('Auth')
@Controller('auth')
export class RegisterController {
  constructor(
    private readonly registerUser: RegisterUserUseCase,
    private readonly assembler: UserPublicAssembler,
  ) {}

  /**
   * POST /auth/register
   *
   * Registra un nuevo usuario en la plataforma.
   * Retorna datos públicos del usuario (sin contraseña).
   *
   * @param dto Datos de entrada validados (email, name, password, avatarUrl)
   * @returns UserPublicResponseDto con los datos del nuevo usuario.
   */
  @Post('register')
  @Throttle({ default: { ttl: 60, limit: 5 } }) // Rate Limit de 5 peticiones por 60s en este endpoint
  @ApiOperation({ summary: 'Registro de nuevo usuario' })
  @ApiCreatedResponse({
    description: 'Usuario creado correctamente',
    type: UserPublicResponseDto,
  })
  @ApiBadRequestResponse({
    description:
      'Solicitud inválida o contraseña débil. (WEAK_PASSWORD / BAD_REQUEST)',
  })
  @ApiConflictResponse({
    description:
      'El correo ya está registrado. (EMAIL_ALREADY_IN_USE / CONFLICT)',
  })
  async register(
    @Body() dto: RegisterUserRequestDto,
  ): Promise<UserPublicResponseDto> {
    const user = await this.registerUser.execute(dto);
    return this.assembler.toDto(user);
  }
}