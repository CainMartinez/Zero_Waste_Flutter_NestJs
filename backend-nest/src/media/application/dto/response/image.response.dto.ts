import { ApiProperty } from '@nestjs/swagger';

export class ImageResponseDto {
  @ApiProperty({ example: 1 })
  id: number;

  @ApiProperty({ example: 'products-1699401234567-product-image.jpg' })
  slug: string;

  @ApiProperty({ example: '1699401234567-product-image.jpg' })
  fileName: string;

  @ApiProperty({ example: '/images/products/1699401234567-product-image.jpg' })
  path: string;

  @ApiProperty({ 
    example: 'https://dominio.es/images/products/1699401234567-product-image.jpg',
    description: 'URL completa (base URL + path)'
  })
  url: string;

  @ApiProperty({ example: 'image/jpeg' })
  mimeType: string;

  @ApiProperty({ example: 245678 })
  size: number;

  @ApiProperty({ example: 1, nullable: true })
  productId: number | null;

  @ApiProperty({ example: null, nullable: true })
  menuId: number | null;

  @ApiProperty({ example: true })
  isActive: boolean;

  @ApiProperty({ example: '2024-11-08T10:30:00Z' })
  createdAt: Date;

  @ApiProperty({ example: '2024-11-08T10:30:00Z' })
  updatedAt: Date;
}
