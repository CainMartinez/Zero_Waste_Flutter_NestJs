import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Product } from '../../../domain/models/product.model';
import { IProductRepository } from '../../../domain/repositories/product.repository';
import { ProductOrmEntity } from '../entities/product.orm-entity';

@Injectable()
export class ProductTypeOrmRepository extends IProductRepository {
  constructor(
    @InjectRepository(ProductOrmEntity)
    private readonly repository: Repository<ProductOrmEntity>,
  ) {
    super();
  }

  async findAllVisible(): Promise<Product[]> {
    const records = await this.repository.find({
      where: { isActive: true },
      relations: ['category'],
      order: { id: 'ASC' },
    });

    return records.map((record) =>
      Product.fromPrimitives({
        id: record.id,
        uuid: record.uuid,
        nameEs: record.nameEs,
        nameEn: record.nameEn,
        descriptionEs: record.descriptionEs,
        descriptionEn: record.descriptionEn,
        price: Number(record.price),
        currency: record.currency,
        isVegan: Boolean(record.isVegan),
        isActive: Boolean(record.isActive),
        categoryCode: record.category?.code,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      }),
    );
  }
}
