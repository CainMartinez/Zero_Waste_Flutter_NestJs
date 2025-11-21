import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { IProductAdminRepository } from '../../../domain/repositories/product-admin.repository';
import { Product } from '../../../../shop/domain/entities/product.entity';
import { Category } from '../../../../shop/domain/entities/category.entity';
import { ProductOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/product.orm-entity';
import { CategoryOrmEntity } from '../../../../shop/infrastructure/typeorm/entities-orm/category.orm-entity';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class ProductAdminTypeOrmRepository implements IProductAdminRepository {
  constructor(
    @InjectRepository(ProductOrmEntity)
    private readonly productRepo: Repository<ProductOrmEntity>,
    @InjectRepository(CategoryOrmEntity)
    private readonly categoryRepo: Repository<CategoryOrmEntity>,
  ) {}

  async findAll(): Promise<Product[]> {
    const entities = await this.productRepo.find({
      relations: ['category', 'images', 'allergens', 'allergens.allergen'],
      order: { createdAt: 'DESC' },
    });

    return entities.map((e) => this.toDomainWithCategoryData(e));
  }

  async findById(id: number): Promise<Product | null> {
    const entity = await this.productRepo.findOne({
      where: { id },
      relations: ['category', 'images', 'allergens', 'allergens.allergen'],
    });

    return entity ? this.toDomainWithCategoryData(entity) : null;
  }

  async findByUuid(uuid: string): Promise<Product | null> {
    const entity = await this.productRepo.findOne({
      where: { uuid },
      relations: ['category', 'images', 'allergens', 'allergens.allergen'],
    });

    return entity ? this.toDomainWithCategoryData(entity) : null;
  }

  async create(data: Partial<Product> & { categoryId: number }): Promise<Product> {
    const category = await this.categoryRepo.findOne({
      where: { id: data.categoryId },
    });

    if (!category) {
      throw new NotFoundException(`Categoría con ID ${data.categoryId} no encontrada`);
    }

    const entity = this.productRepo.create({
      uuid: uuidv4(),
      nameEs: data.nameEs,
      nameEn: data.nameEn,
      descriptionEs: data.descriptionEs,
      descriptionEn: data.descriptionEn,
      price: data.price,
      currency: data.currency || 'EUR',
      isVegan: data.isVegan ?? false,
      isActive: true,
      category,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    const saved = await this.productRepo.save(entity);
    return this.toDomainWithCategoryData(saved);
  }

  async update(id: number, data: Partial<Product> & { categoryId?: number }): Promise<Product> {
    const entity = await this.productRepo.findOne({
      where: { id },
      relations: ['category'],
    });

    if (!entity) {
      throw new NotFoundException(`Producto con ID ${id} no encontrado`);
    }

    // Si se proporciona categoryId, actualizar la categoría
    if (data.categoryId !== undefined) {
      const category = await this.categoryRepo.findOne({
        where: { id: data.categoryId },
      });

      if (!category) {
        throw new NotFoundException(`Categoría con ID ${data.categoryId} no encontrada`);
      }

      entity.category = category;
    }

    // Actualizar campos opcionales
    if (data.nameEs !== undefined) entity.nameEs = data.nameEs;
    if (data.nameEn !== undefined) entity.nameEn = data.nameEn;
    if (data.descriptionEs !== undefined) entity.descriptionEs = data.descriptionEs;
    if (data.descriptionEn !== undefined) entity.descriptionEn = data.descriptionEn;
    if (data.price !== undefined) entity.price = data.price;
    if (data.currency !== undefined) entity.currency = data.currency;
    if (data.isVegan !== undefined) entity.isVegan = data.isVegan;

    entity.updatedAt = new Date();

    const saved = await this.productRepo.save(entity);
    return this.toDomainWithCategoryData(saved);
  }

  async softDelete(id: number): Promise<void> {
    const entity = await this.productRepo.findOne({ where: { id } });

    if (!entity) {
      throw new NotFoundException(`Producto con ID ${id} no encontrado`);
    }

    entity.isActive = false;
    entity.updatedAt = new Date();

    await this.productRepo.save(entity);
  }

  async reactivate(id: number): Promise<Product> {
    const entity = await this.productRepo.findOne({
      where: { id },
      relations: ['category'],
    });

    if (!entity) {
      throw new NotFoundException(`Producto con ID ${id} no encontrado`);
    }

    entity.isActive = true;
    entity.updatedAt = new Date();

    const saved = await this.productRepo.save(entity);
    return this.toDomainWithCategoryData(saved);
  }

  private toDomainWithCategoryData(entity: ProductOrmEntity): Product & { 
    categoryData?: { id: number; code: string; nameEs: string; nameEn: string };
    images?: Array<{ id: number; path: string; fileName: string }>;
    allergens?: Array<{ code: string; nameEs: string; nameEn: string; contains: boolean; mayContain: boolean }>;
  } {
    const product = new Product({
      id: entity.id,
      uuid: entity.uuid,
      nameEs: entity.nameEs,
      nameEn: entity.nameEn,
      descriptionEs: entity.descriptionEs,
      descriptionEn: entity.descriptionEn,
      price: entity.price,
      currency: entity.currency,
      isVegan: entity.isVegan,
      isActive: entity.isActive,
      category: entity.category ? new Category(entity.category.code) : undefined,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    });

    // Añadir datos extra de categoría, imágenes y alérgenos
    return Object.assign(product, {
      categoryData: entity.category ? {
        id: entity.category.id,
        code: entity.category.code,
        nameEs: entity.category.nameEs || '',
        nameEn: entity.category.nameEn || '',
      } : undefined,
      images: entity.images?.map(img => ({
        id: img.id,
        path: img.path,
        fileName: img.fileName,
      })) || [],
      allergens: entity.allergens?.filter(pa => pa.isActive).map(pa => ({
        code: pa.allergenCode,
        nameEs: pa.allergen?.nameEs || pa.allergenCode,
        nameEn: pa.allergen?.nameEn || pa.allergenCode,
        contains: pa.contains,
        mayContain: pa.mayContain,
      })) || [],
    });
  }
}
