import { Injectable, Inject, BadRequestException } from '@nestjs/common';
import type { ImageRepository } from '../../domain/repositories/image.repository';
import { MinioClientService } from '../../infrastructure/adapters/minio-client.service';
import { Image } from '../../domain/entities/image.entity';

@Injectable()
export class UploadImageUseCase {
  constructor(
    @Inject('ImageRepository')
    private readonly imageRepository: ImageRepository,
    private readonly minioService: MinioClientService,
  ) {}

  /**
   * Sube una imagen y guarda su registro en la base de datos
   * Una imagen puede estar asociada a un producto, a un menú, a ambos, o a ninguno
   */
  async execute(
    file: Express.Multer.File,
    productId?: number,
    menuId?: number,
  ): Promise<Image> {
    // Convertir strings vacíos o NaN a undefined
    const validProductId = productId && !isNaN(Number(productId)) ? Number(productId) : undefined;
    const validMenuId = menuId && !isNaN(Number(menuId)) ? Number(menuId) : undefined;

    // Determinar el tipo de bucket según la entidad (prioridad: product > menu > category)
    let type: 'product' | 'menu' | 'category' = 'category';
    if (validProductId) {
      type = 'product';
    } else if (validMenuId) {
      type = 'menu';
    }

    // Subir a MinIO
    const { slug, fileName, path } = await this.minioService.uploadFile(file, type);

    // Guardar registro en la base de datos
    const image = new Image({
      slug,
      fileName,
      path,
      mimeType: file.mimetype,
      size: file.size,
      productId: validProductId,
      menuId: validMenuId,
      isActive: true,
    });

    return await this.imageRepository.create(image);
  }
}
