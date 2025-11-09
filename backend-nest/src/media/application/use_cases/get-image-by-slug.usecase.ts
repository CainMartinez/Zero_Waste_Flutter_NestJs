import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { Image } from '../../domain/entities/image.entity';

@Injectable()
export class GetImageBySlugUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
  ) {}

  /**
   * Obtiene una imagen por su slug
   */
  async execute(slug: string): Promise<Image> {
    const image = await this.imageRepository.findBySlug(slug);
    
    if (!image) {
      throw new NotFoundException('Imagen no encontrada');
    }
    
    return image;
  }
}
