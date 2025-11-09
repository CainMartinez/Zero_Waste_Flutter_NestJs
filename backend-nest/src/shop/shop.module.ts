import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ListProductsUseCase } from './application/use_cases/list-products.usecase';
import { ProductAssembler } from './presentation/assemblers/product.assembler';
import { ProductsController } from './presentation/controllers/product.controller';
import { IProductRepository } from './domain/repositories/product.repository';
import { ProductOrmEntity } from './infrastructure/typeorm/entities-orm/product.orm-entity';
import { CategoryOrmEntity } from './infrastructure/typeorm/entities-orm/category.orm-entity';
import { ProductTypeOrmRepository } from './infrastructure/typeorm/repositories/product.typeorm.repository';
import { AllergenOrmEntity } from './infrastructure/typeorm/entities-orm/allergen.orm-entity';
import { RescueMenuOrmEntity } from './infrastructure/typeorm/entities-orm/rescue-menu.orm-entity';
import { ProductAllergenOrmEntity } from './infrastructure/typeorm/entities-orm/product-allergen.orm-entity';
// import { SeedOnBootProvider } from './../db/seed-on-boot.provider';

@Module({
  imports: [TypeOrmModule.forFeature([ProductOrmEntity, CategoryOrmEntity, AllergenOrmEntity, RescueMenuOrmEntity, ProductAllergenOrmEntity])],
  controllers: [ProductsController],
  providers: [
    ProductAssembler,
    ListProductsUseCase,
    ProductTypeOrmRepository,
    // SeedOnBootProvider,
    {
      provide: IProductRepository,
      useExisting: ProductTypeOrmRepository,
    },
  ],
  exports: [ListProductsUseCase],
})
export class ShopModule {}
