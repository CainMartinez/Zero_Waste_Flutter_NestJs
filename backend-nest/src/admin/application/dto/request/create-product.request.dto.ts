import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean, IsNotEmpty, IsNumber, IsOptional, IsPositive, IsString, Length, MaxLength, Min } from 'class-validator';

export class CreateProductRequestDto {
  @ApiProperty({
    description: 'Nombre del producto en español',
    example: 'Pizza Margarita',
    maxLength: 190,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(190)
  nameEs: string;

  @ApiProperty({
    description: 'Nombre del producto en inglés',
    example: 'Margherita Pizza',
    maxLength: 190,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(190)
  nameEn: string;

  @ApiProperty({
    description: 'Descripción del producto en español',
    example: 'Pizza clásica italiana con tomate, mozzarella y albahaca fresca',
  })
  @IsString()
  @IsNotEmpty()
  descriptionEs: string;

  @ApiProperty({
    description: 'Descripción del producto en inglés',
    example: 'Classic Italian pizza with tomato, mozzarella and fresh basil',
  })
  @IsString()
  @IsNotEmpty()
  descriptionEn: string;

  @ApiProperty({
    description: 'Precio del producto',
    example: 8.50,
    minimum: 0,
  })
  @IsNumber({ maxDecimalPlaces: 2 })
  @IsPositive()
  @Min(0)
  price: number;

  @ApiProperty({
    description: 'Código de moneda (ISO 4217)',
    example: 'EUR',
    default: 'EUR',
    maxLength: 3,
  })
  @IsString()
  @Length(3, 3)
  @IsOptional()
  currency?: string;

  @ApiProperty({
    description: 'Indica si el producto es vegano',
    example: false,
    default: false,
  })
  @IsBoolean()
  @IsOptional()
  isVegan?: boolean;

  @ApiProperty({
    description: 'ID de la categoría del producto',
    example: 1,
  })
  @IsNumber()
  @IsPositive()
  categoryId: number;
}
