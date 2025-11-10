import { ApiProperty } from '@nestjs/swagger';

export class CatalogItemResponseDto {
  @ApiProperty({ example: 1 })
  id: number;

  @ApiProperty({ example: '550e8400-e29b-41d4-a716-446655440000' })
  uuid: string;

  @ApiProperty({ example: 'product', enum: ['product', 'menu'] })
  type: 'product' | 'menu';

  @ApiProperty({ example: 'Hamburguesa Clásica' })
  nameEs: string;

  @ApiProperty({ example: 'Classic Burger' })
  nameEn: string;

  @ApiProperty({ example: 'Deliciosa hamburguesa con queso' })
  descriptionEs: string;

  @ApiProperty({ example: 'Delicious cheeseburger' })
  descriptionEn: string;

  @ApiProperty({ example: 8.50 })
  price: number;

  @ApiProperty({ example: 'EUR' })
  currency: string;

  @ApiProperty({ example: false })
  isVegan: boolean;

  @ApiProperty({
    example: { code: 'MAINS', nameEs: 'Principales', nameEn: 'Mains' },
    description: 'Categoría del producto/menú con nombres en español e inglés',
  })
  category: { code: string; nameEs: string; nameEn: string };

  @ApiProperty({
    example: [
      { code: 'GLUTEN', nameEs: 'Gluten', nameEn: 'Gluten' },
      { code: 'MILK', nameEs: 'Lácteos', nameEn: 'Milk' }
    ],
    description: 'Alérgenos que contiene el producto/menú con nombres en español e inglés',
  })
  allergens: Array<{ code: string; nameEs: string; nameEn: string }>;

  @ApiProperty({
    example: [],
    description: 'URLs de las imágenes asociadas',
  })
  images: string[];

  @ApiProperty({
    example: null,
    description: 'Composición del menú (solo para type=menu)',
    nullable: true,
    required: false,
  })
  menuComposition?: {
    drinkId: number;
    starterId: number;
    mainId: number;
    dessertId: number;
  } | null;

  @ApiProperty({ example: '2024-11-09T10:30:00Z' })
  createdAt: Date;

  @ApiProperty({ example: '2024-11-09T10:30:00Z' })
  updatedAt: Date;
}
