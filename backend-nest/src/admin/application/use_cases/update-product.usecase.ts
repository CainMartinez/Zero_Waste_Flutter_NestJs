import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { IProductAdminRepository } from '../../domain/repositories/product-admin.repository';
import { UpdateProductRequestDto } from '../../application/dto/request/update-product.request.dto';
import { ProductAdminResponseDto } from '../../application/dto/response/product-admin.response.dto';
import { Product } from '../../../shop/domain/entities/product.entity';

@Injectable()
export class UpdateProductUseCase {
  constructor(
    @Inject('IProductAdminRepository')
    private readonly productAdminRepo: IProductAdminRepository,
  ) {}

  async execute(id: number, dto: UpdateProductRequestDto): Promise<ProductAdminResponseDto> {
    const product = await this.productAdminRepo.update(id, {
      nameEs: dto.nameEs,
      nameEn: dto.nameEn,
      descriptionEs: dto.descriptionEs,
      descriptionEn: dto.descriptionEn,
      price: dto.price,
      currency: dto.currency,
      isVegan: dto.isVegan,
      categoryId: dto.categoryId,
    });

    return this.toDto(product);
  }

  private toDto(product: Product & { 
    categoryData?: { id: number; code: string; nameEs: string; nameEn: string };
    images?: Array<{ id: number; path: string; fileName: string }>;
    allergens?: Array<{ code: string; nameEs: string; nameEn: string; contains: boolean; mayContain: boolean }>;
  }): ProductAdminResponseDto {
    return {
      id: product.id,
      uuid: product.uuid,
      nameEs: product.nameEs,
      nameEn: product.nameEn,
      descriptionEs: product.descriptionEs,
      descriptionEn: product.descriptionEn,
      price: Number(product.price),
      currency: product.currency,
      isVegan: product.isVegan,
      isActive: product.isActive,
      categoryId: product.categoryData?.id || null,
      categoryCode: product.categoryData?.code || product.category?.code || null,
      categoryNameEs: product.categoryData?.nameEs || null,
      categoryNameEn: product.categoryData?.nameEn || null,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      images: product.images || [],
      allergens: product.allergens || [],
    };
  }
}
