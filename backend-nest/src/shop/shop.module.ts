import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ListProductsUseCase } from './application/use_cases/list-products.usecase';
import { ProductAssembler } from './presentation/assemblers/product.assembler';
import { ProductsController } from './presentation/controllers/product.controller';
import { IProductRepository } from './domain/repositories/product.repository';
import { ProductOrmEntity } from './infrastructure/typeorm/entities/product.orm-entity';
import { CategoryOrmEntity } from './infrastructure/typeorm/entities/category.orm-entity';
import { ProductTypeOrmRepository } from './infrastructure/typeorm/repositories/product.typeorm.repository';

@Module({
  imports: [TypeOrmModule.forFeature([ProductOrmEntity, CategoryOrmEntity])],
  controllers: [ProductsController],
  providers: [
    ProductAssembler,
    ListProductsUseCase,
    ProductTypeOrmRepository,
    {
      provide: IProductRepository,
      useExisting: ProductTypeOrmRepository,
    },
  ],
  exports: [ListProductsUseCase],
})
export class ShopModule {}
