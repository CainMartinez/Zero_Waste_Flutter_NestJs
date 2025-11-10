import { ApiProperty } from '@nestjs/swagger';

export class PaginatedResponseDto<T> {
  @ApiProperty({
    description: 'Lista de elementos de la página actual',
    isArray: true,
  })
  items: T[];

  @ApiProperty({
    description: 'Cursor para la siguiente página (ID del último elemento)',
    example: 25,
    nullable: true,
  })
  nextCursor: number | null;

  @ApiProperty({
    description: 'Indica si hay más elementos disponibles',
    example: true,
  })
  hasMore: boolean;

  @ApiProperty({
    description: 'Total de elementos que cumplen los filtros',
    example: 150,
  })
  total: number;

  @ApiProperty({
    description: 'Cantidad de elementos en la página actual',
    example: 20,
  })
  count: number;

  constructor(
    items: T[],
    total: number,
    limit: number,
    nextCursor: number | null = null,
  ) {
    this.items = items;
    this.nextCursor = nextCursor;
    this.hasMore = nextCursor !== null;
    this.total = total;
    this.count = items.length;
  }
}
