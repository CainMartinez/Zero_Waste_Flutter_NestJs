import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { MinioClientService } from '../../infrastructure/adapters/minio-client.service';

@Injectable()
export class DeleteImageUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
    private readonly minioService: MinioClientService,
  ) {}

  /**
   * Elimina una imagen (soft delete en DB y físicamente en MinIO)
   */
  async execute(slug: string): Promise<void> {
    const image = await this.imageRepository.findBySlug(slug);
    
    if (!image) {
      throw new NotFoundException('Imagen no encontrada');
    }

    // Extraer bucket del slug (formato: {bucket}-{timestamp}-{nombre})
    const bucket = slug.split('-')[0];
    
    // Eliminar físicamente de MinIO
    await this.minioService.deleteFile(bucket, image.fileName);

    // Soft delete en la base de datos
    await this.imageRepository.delete(image.id!);
  }
}
