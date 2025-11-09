import { Injectable, Inject } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { Image } from '../../domain/entities/image.entity';

@Injectable()
export class GetImagesByMenuUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
  ) {}

  /**
   * Obtiene todas las imágenes de un menú
   */
  async execute(menuId: number): Promise<Image[]> {
    return await this.imageRepository.findByMenuId(menuId);
  }
}
