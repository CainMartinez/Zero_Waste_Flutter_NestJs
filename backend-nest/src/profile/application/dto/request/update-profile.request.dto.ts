import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, MaxLength, Matches } from 'class-validator';

export class UpdateProfileRequestDto {
  @ApiPropertyOptional({
    description: 'Teléfono del usuario',
    example: '+34612345678',
  })
  @IsOptional()
  @IsString()
  @MaxLength(20)
  phone?: string;

  @ApiPropertyOptional({
    description: 'Línea 1 de dirección',
    example: 'Calle Mayor 123',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  addressLine1?: string;

  @ApiPropertyOptional({
    description: 'Línea 2 de dirección (opcional)',
    example: 'Piso 2, Puerta A',
  })
  @IsOptional()
  @IsString()
  @MaxLength(255)
  addressLine2?: string;

  @ApiPropertyOptional({
    description: 'Ciudad',
    example: 'Madrid',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  city?: string;

  @ApiPropertyOptional({
    description: 'Código postal',
    example: '28001',
  })
  @IsOptional()
  @IsString()
  @MaxLength(10)
  postalCode?: string;

  @ApiPropertyOptional({
    description: 'Código de país (ISO 3166-1 alpha-2)',
    example: 'ES',
  })
  @IsOptional()
  @IsString()
  @Matches(/^[A-Z]{2}$/, { message: 'El código de país debe ser de 2 letras mayúsculas (ej: ES)' })
  countryCode?: string;

  @ApiPropertyOptional({
    description: 'URL del avatar del usuario',
    example: 'https://example.com/avatar.jpg',
  })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  avatarUrl?: string;
}
