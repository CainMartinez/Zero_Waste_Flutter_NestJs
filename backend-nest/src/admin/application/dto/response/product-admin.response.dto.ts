import { ApiProperty } from '@nestjs/swagger';

export class ProductAdminResponseDto {
  @ApiProperty({
    description: 'ID interno del producto',
    example: 1,
  })
  id: number;

  @ApiProperty({
    description: 'UUID del producto',
    example: '550e8400-e29b-41d4-a716-446655440000',
  })
  uuid: string;

  @ApiProperty({
    description: 'Nombre del producto en español',
    example: 'Pizza Margarita',
  })
  nameEs: string;

  @ApiProperty({
    description: 'Nombre del producto en inglés',
    example: 'Margherita Pizza',
  })
  nameEn: string;

  @ApiProperty({
    description: 'Descripción del producto en español',
    example: 'Pizza clásica italiana con tomate, mozzarella y albahaca fresca',
  })
  descriptionEs: string;

  @ApiProperty({
    description: 'Descripción del producto en inglés',
    example: 'Classic Italian pizza with tomato, mozzarella and fresh basil',
  })
  descriptionEn: string;

  @ApiProperty({
    description: 'Precio del producto',
    example: 8.50,
  })
  price: number;

  @ApiProperty({
    description: 'Código de moneda (ISO 4217)',
    example: 'EUR',
  })
  currency: string;

  @ApiProperty({
    description: 'Indica si el producto es vegano',
    example: false,
  })
  isVegan: boolean;

  @ApiProperty({
    description: 'Indica si el producto está activo',
    example: true,
  })
  isActive: boolean;

  @ApiProperty({
    description: 'ID de la categoría',
    example: 1,
    nullable: true,
  })
  categoryId: number | null;

  @ApiProperty({
    description: 'Código de la categoría',
    example: 'PIZZAS',
    nullable: true,
  })
  categoryCode: string | null;

  @ApiProperty({
    description: 'Nombre de la categoría en español',
    example: 'Pizzas',
    nullable: true,
  })
  categoryNameEs: string | null;

  @ApiProperty({
    description: 'Nombre de la categoría en inglés',
    example: 'Pizzas',
    nullable: true,
  })
  categoryNameEn: string | null;

  @ApiProperty({
    description: 'Fecha de creación',
    example: '2024-01-01T12:00:00.000Z',
  })
  createdAt: Date;

  @ApiProperty({
    description: 'Fecha de última actualización',
    example: '2024-01-01T12:00:00.000Z',
  })
  updatedAt: Date;
}
