import { Product } from '../models/product.model';

export abstract class IProductRepository {
  abstract findAllVisible(): Promise<Product[]>;
}