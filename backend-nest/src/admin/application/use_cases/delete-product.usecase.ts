import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { IProductAdminRepository } from '../../domain/repositories/product-admin.repository';

@Injectable()
export class DeleteProductUseCase {
  constructor(
    @Inject('IProductAdminRepository')
    private readonly productAdminRepo: IProductAdminRepository,
  ) {}

  async execute(id: number): Promise<void> {
    await this.productAdminRepo.softDelete(id);
  }
}
