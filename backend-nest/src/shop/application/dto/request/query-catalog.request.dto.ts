import { IsOptional, IsString, IsBoolean, IsArray, IsEnum, IsInt, Min } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export enum SortBy {
  PRICE = 'price',
  NAME = 'name',
  CREATED_AT = 'createdAt',
}

export enum SortOrder {
  ASC = 'asc',
  DESC = 'desc',
}

export class QueryCatalogRequestDto {
  @ApiPropertyOptional({
    description: 'Filtrar por código de categoría',
    example: 'DRINKS',
    enum: ['DRINKS', 'STARTERS', 'MAINS', 'BOWLS', 'DESSERTS', 'SNACKS', 'MENUS'],
  })
  @IsOptional()
  @IsString()
  categoryCode?: string;

  @ApiPropertyOptional({
    description: 'Filtrar solo productos/menús veganos (true = solo veganos, false = solo no veganos)',
    example: true,
  })
  @IsOptional()
  @Transform(({ value }) => {
    // Handle boolean directly
    if (typeof value === 'boolean') return value;
    
    // Handle string representations
    if (value === 'true') return true;
    if (value === 'false') return false;
    
    // Handle numeric representations
    if (value === 1 || value === '1') return true;
    if (value === 0 || value === '0') return false;
    
    // undefined or null
    return undefined;
  }, { toClassOnly: true })
  @IsBoolean()
  isVegan?: boolean;

  @ApiPropertyOptional({
    description: 'Excluir productos/menús que contengan estos alérgenos (filtrado inverso)',
    example: ['GLUTEN', 'MILK'],
    type: [String],
    enum: ['GLUTEN', 'CRUSTACEANS', 'EGGS', 'FISH', 'PEANUTS', 'SOY', 'MILK', 'NUTS', 'CELERY', 'MUSTARD', 'SESAME', 'SULPHITES', 'LUPIN', 'MOLLUSCS'],
  })
  @IsOptional()
  @Transform(({ value }) => {
    
    // Handle null, undefined, empty string
    if (value === null || value === undefined || value === '' || value === 'undefined') {
      return [];
    }
    
    // Already an array - return as is
    if (Array.isArray(value)) {
      const filtered = value.filter(v => v && v !== '');
      return filtered;
    }
    
    // String value - could be single or comma-separated
    if (typeof value === 'string') {
      const trimmed = value.trim();
      if (trimmed === '') {
        return [];
      }
      
      // Check if comma-separated
      if (trimmed.includes(',')) {
        const result = trimmed.split(',').map(v => v.trim()).filter(v => v.length > 0);
        return result;
      }
      
      // Single value
      return [trimmed];
    }
    
    // Fallback: convert to string and wrap in array
    const fallback = [String(value)];
    return fallback;
  }, { toClassOnly: true })
  excludeAllergens?: string[];

  @ApiPropertyOptional({
    description: 'Campo por el cual ordenar',
    enum: SortBy,
    default: SortBy.CREATED_AT,
  })
  @IsOptional()
  @IsEnum(SortBy)
  sortBy?: SortBy;

  @ApiPropertyOptional({
    description: 'Orden ascendente o descendente',
    enum: SortOrder,
    default: SortOrder.DESC,
  })
  @IsOptional()
  @IsEnum(SortOrder)
  sortOrder?: SortOrder;

  @ApiPropertyOptional({
    description: 'Cursor para paginación (ID del último elemento de la página anterior)',
    example: null,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  cursor?: number;

  @ApiPropertyOptional({
    description: 'Cantidad de elementos por página (máximo 50)',
    example: 20,
    default: 20,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number;
}
