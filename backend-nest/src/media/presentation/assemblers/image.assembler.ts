import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ImageResponseDto } from '../../application/dto/response/image.response.dto';
import { Image } from '../../domain/entities/image.entity';

@Injectable()
export class ImageAssembler {
  constructor(private readonly configService: ConfigService) {}

  /**
   * Convierte una entidad de dominio Image a ImageResponseDto
   */
  toDto(image: Image): ImageResponseDto {
    const baseUrl = this.configService.get<string>('MINIO_PUBLIC_URL') || 'http://localhost:9000';
    
    const dto = new ImageResponseDto();
    dto.id = image.id!;
    dto.slug = image.slug;
    dto.fileName = image.fileName;
    dto.path = image.path;
    dto.url = image.getFullUrl(baseUrl); // Construir URL completa
    dto.mimeType = image.mimeType;
    dto.size = image.size;
    dto.productId = image.productId ?? null;
    dto.menuId = image.menuId ?? null;
    dto.isActive = image.isActive;
    dto.createdAt = image.createdAt!;
    dto.updatedAt = image.updatedAt!;
    return dto;
  }

  /**
   * Convierte un array de entidades Image a array de DTOs
   */
  toDtoArray(images: Image[]): ImageResponseDto[] {
    return images.map((image) => this.toDto(image));
  }
}
