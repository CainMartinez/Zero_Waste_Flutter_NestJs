import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { IProductAdminRepository } from '../../domain/repositories/product-admin.repository';
import { ProductAllergenOrmEntity } from '../../../shop/infrastructure/typeorm/entities-orm/product-allergen.orm-entity';

export interface AllergenInput {
  code: string;
  contains: boolean;
  mayContain?: boolean;
}

@Injectable()
export class UpdateProductAllergensUseCase {
  constructor(
    @Inject('IProductAdminRepository')
    private readonly productRepository: IProductAdminRepository,
    @InjectRepository(ProductAllergenOrmEntity)
    private readonly productAllergenRepository: Repository<ProductAllergenOrmEntity>,
  ) {}

  async execute(productId: number, allergens: AllergenInput[]): Promise<void> {
    // Verificar que el producto existe
    const product = await this.productRepository.findById(productId);
    if (!product) {
      throw new NotFoundException(`Producto con ID ${productId} no encontrado`);
    }

    // HARD DELETE: Eliminar todos los alérgenos actuales del producto
    await this.productAllergenRepository.delete({ productId });

    // Crear los nuevos alérgenos
    if (allergens.length > 0) {
      const newAllergens = allergens.map(allergen => 
        this.productAllergenRepository.create({
          productId,
          allergenCode: allergen.code,
          contains: allergen.contains,
          mayContain: allergen.mayContain ?? false,
          isActive: true,
        })
      );
      
      await this.productAllergenRepository.save(newAllergens);
    }
  }
}
