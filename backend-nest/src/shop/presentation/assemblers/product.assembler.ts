import { Injectable } from '@nestjs/common';
import { ProductResponseDto } from '../../application/dto/product.response.dto';
import { Product } from '../../domain/entities/product.entity';

@Injectable()
export class ProductAssembler {
  /**
   * @param entity Entidad de dominio Product
   * @param locale Idioma preferido ('es' | 'en'), por defecto 'es'
   */
  toResponseDto(entity: Product, locale: 'es' | 'en' = 'es'): ProductResponseDto {
    const dto = new ProductResponseDto();

    dto.id = entity.id;
    dto.uuid = entity.uuid;

    // Selección simple por locale; si no existe, cae al otro idioma.
    const nameEs = (entity as any).nameEs ?? (entity as any).name_es;
    const nameEn = (entity as any).nameEn ?? (entity as any).name_en;
    const descEs = (entity as any).descriptionEs ?? (entity as any).description_es;
    const descEn = (entity as any).descriptionEn ?? (entity as any).description_en;

    dto.name = (locale === 'en' ? nameEn : nameEs) ?? nameEs ?? nameEn ?? '';
    dto.description = (locale === 'en' ? descEn : descEs) ?? descEs ?? descEn ?? '';

    dto.price = entity.price;
    dto.currency = entity.currency;
    dto.isVegan = entity.isVegan;

    // Suponemos que la entidad tiene category con code; si no, queda vacío.
    dto.categoryCode = entity.category?.code ?? '';

    dto.isActive = entity.isActive;
    dto.createdAt = entity.createdAt;
    dto.updatedAt = entity.updatedAt;

    return dto;
  }
}