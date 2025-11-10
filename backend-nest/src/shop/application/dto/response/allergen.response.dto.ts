import { ApiProperty } from '@nestjs/swagger';

export class AllergenResponseDto {
  @ApiProperty({ example: 'gluten' })
  code: string;

  @ApiProperty({ example: 'Gluten' })
  nameEs: string;

  @ApiProperty({ example: 'Gluten' })
  nameEn: string;
}
