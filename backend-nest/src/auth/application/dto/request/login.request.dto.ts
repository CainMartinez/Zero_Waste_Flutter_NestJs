import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';
import { Transform } from 'class-transformer';

/**
 * Payload de entrada para /auth/login
 * Se valida con ValidationPipe global para devolver 400 si es inválido.
 */
export class LoginRequestDto {
  @ApiProperty({ example: 'usuario@example.com' })
  @IsEmail({}, { message: 'email: formato inválido' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim().toLowerCase() : value))
  email!: string;

  @ApiProperty({ example: 'C0ntr4seña_Segura' })
  @IsString({ message: 'password: debe ser texto' })
  @MinLength(8, { message: 'password: mínimo 8 caracteres' })
  @MaxLength(255, { message: 'password: máximo 255 caracteres' })
  password!: string;
}