import { ApiProperty } from '@nestjs/swagger';
import { IsJWT } from 'class-validator';

/**
 * Payload de entrada para /auth/refresh.
 * Valida que el refresh token tenga un formato JWT correcto.
 */
export class RefreshTokenRequestDto {
  @ApiProperty({
    description: 'Refresh token JWT previamente emitido.',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  @IsJWT({ message: 'refreshToken: formato JWT inválido' })
  refreshToken!: string;
}