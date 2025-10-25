import { ApiProperty } from '@nestjs/swagger';
import { UserPublicResponseDto } from './user-public.response.dto';

/**
 * DTO de salida para /auth/login
 * Contiene los tokens de autenticación y los datos públicos del usuario.
 */
export class LoginResponseDto {
  @ApiProperty({
    description: 'Token JWT de acceso (válido para llamadas autenticadas).',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken!: string;

  @ApiProperty({
    description: 'Datos públicos del usuario autenticado.',
    type: UserPublicResponseDto,
  })
  user!: UserPublicResponseDto;
}