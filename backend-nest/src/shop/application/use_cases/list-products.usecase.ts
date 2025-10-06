import { Inject, Injectable } from '@nestjs/common';
import { ProductResponseDto } from '../dto/product.response.dto';
import { Product } from '../../domain/entities/product.entity';
import { IProductRepository } from '../../domain/repositories/product.repository';
import { ProductAssembler } from '../../presentation/assemblers/product.assembler';

@Injectable()
export class ListProductsUseCase {
  constructor(
    @Inject(IProductRepository)
    private readonly productRepository: IProductRepository,
    private readonly productAssembler: ProductAssembler,
  ) {}

  async execute(): Promise<ProductResponseDto[]> {
    const products: Product[] = await this.productRepository.findAllVisible();
    return products.map((p) => this.productAssembler.toResponseDto(p));
  }
}
