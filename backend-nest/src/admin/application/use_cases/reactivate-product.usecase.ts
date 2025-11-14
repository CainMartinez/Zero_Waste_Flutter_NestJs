import { Injectable } from '@nestjs/common';
import { IProductAdminRepository } from '../../domain/repositories/product-admin.repository';
import { ProductAdminResponseDto } from '../../application/dto/response/product-admin.response.dto';
import { Product } from '../../../shop/domain/entities/product.entity';

@Injectable()
export class ReactivateProductUseCase {
  constructor(
    private readonly productAdminRepo: IProductAdminRepository,
  ) {}

  async execute(id: number): Promise<ProductAdminResponseDto> {
    const product = await this.productAdminRepo.reactivate(id);
    return this.toDto(product);
  }

  private toDto(product: Product & { categoryData?: { id: number; code: string; nameEs: string; nameEn: string } }): ProductAdminResponseDto {
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
    };
  }
}
