import { ApiProperty } from '@nestjs/swagger';

export class CategoryResponseDto {
  @ApiProperty({ example: 1 })
  id: number;

  @ApiProperty({ example: 'bebidas' })
  code: string;

  @ApiProperty({ example: 'Bebidas' })
  nameEs: string;

  @ApiProperty({ example: 'Drinks' })
  nameEn: string;
}
