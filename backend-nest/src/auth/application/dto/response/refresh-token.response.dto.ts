import { ApiProperty } from '@nestjs/swagger';

/**
 * Respuesta de /auth/refresh cuando se renueva el access token.
 */
export class RefreshAccessResponseDto {
  @ApiProperty({
    description: 'Nuevo token JWT de acceso (válido para llamadas autenticadas).',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken!: string;
}