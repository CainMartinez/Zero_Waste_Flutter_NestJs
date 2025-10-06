import { ApiProperty } from '@nestjs/swagger';

export class ProductResponseDto {
  @ApiProperty({ example: 1, description: 'Identificador interno incremental del producto.' })
  id: number;

  @ApiProperty({
    example: 'a3e91b6d-1c32-4b2f-bd6a-47e7f1eaa5d9',
    description: 'UUID único del producto (usado como referencia externa).',
  })
  uuid: string;

  @ApiProperty({ example: 'Arroz de temporada', description: 'Nombre del producto (localizado).' })
  name: string;

  @ApiProperty({
    example: 'Caldo con restos de verduras de temporada.',
    description: 'Descripción breve del producto.',
  })
  description: string;

  @ApiProperty({ example: 9.5, description: 'Precio de venta unitario.' })
  price: number;

  @ApiProperty({ example: 'EUR', description: 'Moneda en formato ISO 4217.' })
  currency: string;

  @ApiProperty({ example: false, description: 'Indica si el producto es vegano.' })
  isVegan: boolean;

  @ApiProperty({
    example: 'principales',
    description: 'Código de la categoría a la que pertenece el producto.',
  })
  categoryCode: string;

  @ApiProperty({
    example: true,
    description: 'Indica si el producto está activo y visible para los clientes.',
  })
  isActive: boolean;

  @ApiProperty({
    example: '2025-10-06T14:30:00.000Z',
    description: 'Fecha de creación del registro.',
    format: 'date-time',
  })
  createdAt: Date;

  @ApiProperty({
    example: '2025-10-06T15:00:00.000Z',
    description: 'Fecha de la última actualización del registro.',
    format: 'date-time',
  })
  updatedAt: Date;
}