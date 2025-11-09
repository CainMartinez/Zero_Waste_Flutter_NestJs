import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ImageOrmEntity } from '../entities-orm/image.orm-entity';
import { ImageRepository } from '../../../domain/repositories/image.repository';
import { Image } from '../../../domain/entities/image.entity';

@Injectable()
export class ImageRepositoryImpl implements ImageRepository {
  constructor(
    @InjectRepository(ImageOrmEntity)
    private readonly imageRepository: Repository<ImageOrmEntity>,
  ) {}

  async create(image: Image): Promise<Image> {
    const imageOrm = this.imageRepository.create({
      slug: image.slug,
      fileName: image.fileName,
      path: image.path,
      mimeType: image.mimeType,
      size: image.size,
      productId: image.productId,
      menuId: image.menuId,
      isActive: image.isActive ?? true,
    });

    const saved = await this.imageRepository.save(imageOrm);
    return this.toDomain(saved);
  }

  async findById(id: number): Promise<Image | null> {
    const imageOrm = await this.imageRepository.findOne({ where: { id } });
    return imageOrm ? this.toDomain(imageOrm) : null;
  }

  async findBySlug(slug: string): Promise<Image | null> {
    const imageOrm = await this.imageRepository.findOne({ where: { slug } });
    return imageOrm ? this.toDomain(imageOrm) : null;
  }

  async findByProductId(productId: number): Promise<Image[]> {
    const imagesOrm = await this.imageRepository.find({
      where: { productId, isActive: true },
      order: { createdAt: 'DESC' },
    });
    return imagesOrm.map((img) => this.toDomain(img));
  }

  async findByMenuId(menuId: number): Promise<Image[]> {
    const imagesOrm = await this.imageRepository.find({
      where: { menuId, isActive: true },
      order: { createdAt: 'DESC' },
    });
    return imagesOrm.map((img) => this.toDomain(img));
  }

  async update(id: number, image: Partial<Image>): Promise<Image> {
    await this.imageRepository.update(id, {
      ...(image.fileName && { fileName: image.fileName }),
      ...(image.path && { path: image.path }),
      ...(image.isActive !== undefined && { isActive: image.isActive }),
    });
    const updated = await this.findById(id);
    return updated!;
  }

  async delete(id: number): Promise<void> {
    await this.imageRepository.update(id, { isActive: false });
  }

  async deleteBySlug(slug: string): Promise<void> {
    await this.imageRepository.update({ slug }, { isActive: false });
  }

  private toDomain(orm: ImageOrmEntity): Image {
    return new Image({
      id: orm.id,
      slug: orm.slug,
      fileName: orm.fileName,
      path: orm.path,
      mimeType: orm.mimeType,
      size: orm.size,
      productId: orm.productId,
      menuId: orm.menuId,
      isActive: orm.isActive,
      createdAt: orm.createdAt,
      updatedAt: orm.updatedAt,
    });
  }
}
