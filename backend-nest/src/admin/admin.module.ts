import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProductOrmEntity } from '../shop/infrastructure/typeorm/entities-orm/product.orm-entity';
import { CategoryOrmEntity } from '../shop/infrastructure/typeorm/entities-orm/category.orm-entity';
import { ProductsAdminController } from './presentation/controllers/products-admin.controller';
import { IProductAdminRepository } from './domain/repositories/product-admin.repository';
import { ProductAdminTypeOrmRepository } from './infrastructure/typeorm/repositories/product-admin.typeorm.repository';
import { GetAllProductsUseCase } from './application/use_cases/get-all-products.usecase';
import { GetProductByIdUseCase } from './application/use_cases/get-product-by-id.usecase';
import { CreateProductUseCase } from './application/use_cases/create-product.usecase';
import { UpdateProductUseCase } from './application/use_cases/update-product.usecase';
import { DeleteProductUseCase } from './application/use_cases/delete-product.usecase';
import { ReactivateProductUseCase } from './application/use_cases/reactivate-product.usecase';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      ProductOrmEntity,
      CategoryOrmEntity,
    ]),
  ],
  controllers: [ProductsAdminController],
  providers: [
    // Use Cases
    GetAllProductsUseCase,
    GetProductByIdUseCase,
    CreateProductUseCase,
    UpdateProductUseCase,
    DeleteProductUseCase,
    ReactivateProductUseCase,

    // Repositories
    ProductAdminTypeOrmRepository,
    {
      provide: IProductAdminRepository,
      useExisting: ProductAdminTypeOrmRepository,
    },
  ],
  exports: [],
})
export class AdminModule {}
