import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { MinioClientService } from '../../infrastructure/adapters/minio-client.service';

@Injectable()
export class DeleteImageByIdUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
    private readonly minioService: MinioClientService,
  ) {}

  /**
   * Elimina una imagen por ID (soft delete en DB y físicamente en MinIO)
   */
  async execute(id: number): Promise<void> {
    const image = await this.imageRepository.findById(id);
    
    if (!image) {
      throw new NotFoundException('Imagen no encontrada');
    }

    // Extraer bucket del slug (formato: {bucket}-{timestamp}-{nombre})
    const bucket = image.slug.split('-')[0];
    
    // Eliminar físicamente de MinIO
    await this.minioService.deleteFile(bucket, image.fileName);

    // Soft delete en la base de datos
    await this.imageRepository.delete(id);
  }
}
