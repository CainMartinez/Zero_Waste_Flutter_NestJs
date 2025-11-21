import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsBoolean, IsOptional, IsString, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class ProductAllergenItemDto {
  @ApiProperty({
    description: 'Código del alérgeno',
    example: 'gluten',
  })
  @IsString()
  code: string;

  @ApiProperty({
    description: 'Si el producto contiene este alérgeno',
    example: true,
  })
  @IsBoolean()
  contains: boolean;

  @ApiProperty({
    description: 'Si el producto puede contener trazas de este alérgeno',
    example: false,
  })
  @IsBoolean()
  @IsOptional()
  mayContain?: boolean;
}

export class UpdateProductAllergensRequestDto {
  @ApiProperty({
    description: 'Lista de alérgenos del producto',
    type: [ProductAllergenItemDto],
    example: [
      { code: 'gluten', contains: true, mayContain: false },
      { code: 'dairy', contains: false, mayContain: true },
    ],
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ProductAllergenItemDto)
  allergens: ProductAllergenItemDto[];
}
