import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEmail,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { Transform } from 'class-transformer';

/**
 * DTO de entrada para /auth/register
 * - Sanitiza y valida email/name/password.
 */
export class RegisterUserRequestDto {
  @ApiProperty({
    example: 'usuario@example.com',
    description: 'Email del usuario (único, se normaliza a minúsculas).',
  })
  @IsEmail({}, { message: 'email: formato inválido' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim().toLowerCase() : value))
  email!: string;

  @ApiProperty({
    example: 'María Gómez',
    description: 'Nombre visible del usuario.',
  })
  @IsString({ message: 'name: debe ser texto' })
  @MinLength(2, { message: 'name: mínimo 2 caracteres' })
  @MaxLength(190, { message: 'name: máximo 190 caracteres' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  name!: string;

  @ApiProperty({
    example: 'C0ntr4seña_Segura',
    description:
      'Contraseña del usuario. Mínimo 8 caracteres e incluir al menos 1 mayúscula, 1 minúscula y 1 número.',
  })
  @IsString({ message: 'password: debe ser texto' })
  @MinLength(8, { message: 'password: mínimo 8 caracteres' })
  @MaxLength(255, { message: 'password: máximo 255 caracteres' })
  @Matches(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+/, {
    message: 'password: debe incluir mayúscula, minúscula y número',
  })
  password!: string;

  @IsOptional()
  @IsString({ message: 'avatarUrl: debe ser texto' })
  @MaxLength(255, { message: 'avatarUrl: máximo 255 caracteres' })
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  avatarUrl?: string;
}