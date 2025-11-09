import { IsOptional, IsInt, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class UploadImageRequestDto {
  @ApiPropertyOptional({ 
    description: 'ID del producto al que pertenece la imagen (opcional)',
    example: 1,
    type: Number
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'productId debe ser un número entero' })
  @Min(1, { message: 'productId debe ser mayor a 0' })
  productId?: number;

  @ApiPropertyOptional({ 
    description: 'ID del menú al que pertenece la imagen (opcional)',
    example: 1,
    type: Number
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt({ message: 'menuId debe ser un número entero' })
  @Min(1, { message: 'menuId debe ser mayor a 0' })
  menuId?: number;
}
