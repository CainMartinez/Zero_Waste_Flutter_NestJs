import { Injectable, Inject } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { Image } from '../../domain/entities/image.entity';

@Injectable()
export class GetImagesByProductUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
  ) {}

  /**
   * Obtiene todas las imágenes de un producto
   */
  async execute(productId: number): Promise<Image[]> {
    return await this.imageRepository.findByProductId(productId);
  }
}
