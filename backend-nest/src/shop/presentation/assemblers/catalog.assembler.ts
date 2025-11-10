import { Injectable } from '@nestjs/common';
import { CatalogItem } from '../../domain/entities/catalog-item.entity';
import { CatalogItemResponseDto } from '../../application/dto/response/catalog-item.response.dto';
import { PaginatedResponseDto } from '../../application/dto/response/paginated.response.dto';
import { PaginatedResult } from '../../domain/types/catalog-filters.type';

/**
 * Assembler para transformar entidades CatalogItem a DTOs de respuesta
 */
@Injectable()
export class CatalogAssembler {
  /**
   * Transforma el resultado paginado de catalog items a DTO de respuesta
   */
  toPaginatedResponse(
    result: PaginatedResult<CatalogItem>,
  ): PaginatedResponseDto<CatalogItemResponseDto> {
    return {
      items: result.items.map(item => this.toDto(item)),
      nextCursor: result.nextCursor,
      hasMore: result.nextCursor !== null,
      total: result.total,
      count: result.items.length,
    };
  }

  /**
   * Transforma un CatalogItem a CatalogItemResponseDto
   */
  toDto(item: CatalogItem): CatalogItemResponseDto {
    const dto: CatalogItemResponseDto = {
      id: item.id,
      uuid: item.uuid,
      type: item.type,
      nameEs: item.nameEs,
      nameEn: item.nameEn,
      descriptionEs: item.descriptionEs,
      descriptionEn: item.descriptionEn,
      price: item.price,
      currency: item.currency,
      isVegan: item.isVegan,
      category: item.category,
      allergens: item.allergens,
      images: item.images,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    };

    // Agregar menuComposition solo si es un menú
    if (item.type === 'menu' && item.menuComposition) {
      dto.menuComposition = {
        drinkId: item.menuComposition.drinkId,
        starterId: item.menuComposition.starterId,
        mainId: item.menuComposition.mainId,
        dessertId: item.menuComposition.dessertId,
      };
    }

    return dto;
  }
}
