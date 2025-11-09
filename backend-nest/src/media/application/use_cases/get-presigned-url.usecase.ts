import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { MinioClientService } from '../../infrastructure/adapters/minio-client.service';

@Injectable()
export class GetPresignedUrlUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
    private readonly minioService: MinioClientService,
  ) {}

  /**
   * Obtiene la URL pre-firmada de una imagen
   */
  async execute(slug: string, expiry?: number): Promise<string> {
    const image = await this.imageRepository.findBySlug(slug);
    
    if (!image) {
      throw new NotFoundException('Imagen no encontrada');
    }

    // Extraer bucket del slug (formato: {bucket}-{timestamp}-{nombre})
    const bucket = slug.split('-')[0];
    
    return await this.minioService.getPresignedUrl(bucket, image.fileName, expiry);
  }
}
