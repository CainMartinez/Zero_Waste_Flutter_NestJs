import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNumber, IsOptional, IsPositive, IsString, Length, MaxLength, Min } from 'class-validator';

export class UpdateProductRequestDto {
  @ApiProperty({
    description: 'Nombre del producto en español',
    example: 'Pizza Margarita',
    maxLength: 190,
    required: false,
  })
  @IsString()
  @MaxLength(190)
  @IsOptional()
  nameEs?: string;

  @ApiProperty({
    description: 'Nombre del producto en inglés',
    example: 'Margherita Pizza',
    maxLength: 190,
    required: false,
  })
  @IsString()
  @MaxLength(190)
  @IsOptional()
  nameEn?: string;

  @ApiProperty({
    description: 'Descripción del producto en español',
    example: 'Pizza clásica italiana con tomate, mozzarella y albahaca fresca',
    required: false,
  })
  @IsString()
  @IsOptional()
  descriptionEs?: string;

  @ApiProperty({
    description: 'Descripción del producto en inglés',
    example: 'Classic Italian pizza with tomato, mozzarella and fresh basil',
    required: false,
  })
  @IsString()
  @IsOptional()
  descriptionEn?: string;

  @ApiProperty({
    description: 'Precio del producto',
    example: 8.50,
    minimum: 0,
    required: false,
  })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Min(0)
  @IsOptional()
  price?: number;

  @ApiProperty({
    description: 'Código de moneda (ISO 4217)',
    example: 'EUR',
    maxLength: 3,
    required: false,
  })
  @IsString()
  @Length(3, 3)
  @IsOptional()
  currency?: string;

  @ApiProperty({
    description: 'Indica si el producto es vegano',
    example: false,
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  isVegan?: boolean;

  @ApiProperty({
    description: 'ID de la categoría del producto',
    example: 1,
    required: false,
  })
  @IsNumber()
  @IsPositive()
  @IsOptional()
  categoryId?: number;
}
