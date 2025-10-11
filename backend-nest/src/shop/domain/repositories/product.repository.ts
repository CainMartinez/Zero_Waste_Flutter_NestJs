import { Product } from '../entities/product.entity';

export abstract class IProductRepository {
  abstract findAllVisible(): Promise<Product[]>;
}