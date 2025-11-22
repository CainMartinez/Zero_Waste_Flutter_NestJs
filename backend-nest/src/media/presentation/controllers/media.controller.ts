import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  Body,
  UploadedFile,
  UseInterceptors,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { UploadImageUseCase } from '../../application/use_cases/upload-image.usecase';
import { GetImageBySlugUseCase } from '../../application/use_cases/get-image-by-slug.usecase';
import { GetImagesByProductUseCase } from '../../application/use_cases/get-images-by-product.usecase';
import { GetImagesByMenuUseCase } from '../../application/use_cases/get-images-by-menu.usecase';
import { DeleteImageUseCase } from '../../application/use_cases/delete-image.usecase';
import { DeleteImageByIdUseCase } from '../../application/use_cases/delete-image-by-id.usecase';
import { GetPresignedUrlUseCase } from '../../application/use_cases/get-presigned-url.usecase';
import { UploadImageRequestDto } from '../../application/dto/request/upload-image.request.dto';
import { ImageResponseDto } from '../../application/dto/response/image.response.dto';
import { ImageAssembler } from '../assemblers/image.assembler';

@ApiTags('Media')
@Controller('media')
export class MediaController {
  constructor(
    private readonly uploadImageUseCase: UploadImageUseCase,
    private readonly getImageBySlugUseCase: GetImageBySlugUseCase,
    private readonly getImagesByProductUseCase: GetImagesByProductUseCase,
    private readonly getImagesByMenuUseCase: GetImagesByMenuUseCase,
    private readonly deleteImageUseCase: DeleteImageUseCase,
    private readonly deleteImageByIdUseCase: DeleteImageByIdUseCase,
    private readonly getPresignedUrlUseCase: GetPresignedUrlUseCase,
    private readonly imageAssembler: ImageAssembler,
  ) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Subir una imagen asociada a un producto o menú' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
        productId: {
          type: 'number',
          description: 'ID del producto (opcional)',
        },
        menuId: {
          type: 'number',
          description: 'ID del menú (opcional)',
        },
      },
    },
  })
  @ApiResponse({ 
    status: 201, 
    description: 'Imagen subida exitosamente',
    type: ImageResponseDto 
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  async uploadImage(
    @UploadedFile() file: Express.Multer.File,
    @Body() uploadDto: UploadImageRequestDto,
  ): Promise<ImageResponseDto> {
    if (!file) {
      throw new BadRequestException('No se ha proporcionado ningún archivo');
    }

    // Validar tipo de archivo
    const allowedMimeTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    if (!allowedMimeTypes.includes(file.mimetype)) {
      throw new BadRequestException(
        'Tipo de archivo no permitido. Solo se aceptan: JPEG, PNG, WEBP',
      );
    }

    // Validar tamaño (máximo 5MB)
    const maxSize = 5 * 1024 * 1024; // 5MB
    if (file.size > maxSize) {
      throw new BadRequestException('El archivo es demasiado grande. Máximo 5MB');
    }

    const productId = uploadDto.productId ? Number(uploadDto.productId) : undefined;
    const menuId = uploadDto.menuId ? Number(uploadDto.menuId) : undefined;

    const image = await this.uploadImageUseCase.execute(
      file,
      productId,
      menuId,
    );

    return this.imageAssembler.toDto(image);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Obtener información de una imagen por slug' })
  @ApiResponse({ 
    status: 200, 
    description: 'Información de la imagen',
    type: ImageResponseDto 
  })
  @ApiResponse({ status: 404, description: 'Imagen no encontrada' })
  async getImage(@Param('slug') slug: string): Promise<ImageResponseDto> {
    const image = await this.getImageBySlugUseCase.execute(slug);
    return this.imageAssembler.toDto(image);
  }

  @Get('product/:productId')
  @ApiOperation({ summary: 'Obtener todas las imágenes de un producto' })
  @ApiResponse({ 
    status: 200, 
    description: 'Lista de imágenes del producto',
    type: [ImageResponseDto]
  })
  async getImagesByProduct(
    @Param('productId') productId: number,
  ): Promise<ImageResponseDto[]> {
    const images = await this.getImagesByProductUseCase.execute(Number(productId));
    return this.imageAssembler.toDtoArray(images);
  }

  @Get('menu/:menuId')
  @ApiOperation({ summary: 'Obtener todas las imágenes de un menú' })
  @ApiResponse({ 
    status: 200, 
    description: 'Lista de imágenes del menú',
    type: [ImageResponseDto]
  })
  async getImagesByMenu(
    @Param('menuId') menuId: number,
  ): Promise<ImageResponseDto[]> {
    const images = await this.getImagesByMenuUseCase.execute(Number(menuId));
    return this.imageAssembler.toDtoArray(images);
  }

  @Get('slug/:slug/presigned-url')
  @ApiOperation({ summary: 'Obtener URL pre-firmada de una imagen' })
  @ApiResponse({ 
    status: 200, 
    description: 'URL pre-firmada',
    schema: {
      type: 'object',
      properties: {
        url: { type: 'string' }
      }
    }
  })
  @ApiResponse({ status: 404, description: 'Imagen no encontrada' })
  async getPresignedUrl(@Param('slug') slug: string): Promise<{ url: string }> {
    const url = await this.getPresignedUrlUseCase.execute(slug);
    return { url };
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar una imagen por ID' })
  @ApiResponse({ status: 200, description: 'Imagen eliminada exitosamente' })
  @ApiResponse({ status: 404, description: 'Imagen no encontrada' })
  async deleteImageById(@Param('id') id: number): Promise<{ message: string }> {
    await this.deleteImageByIdUseCase.execute(Number(id));
    return { message: 'Imagen eliminada exitosamente' };
  }

  @Delete('slug/:slug')
  @ApiOperation({ summary: 'Eliminar una imagen por slug' })
  @ApiResponse({ status: 200, description: 'Imagen eliminada exitosamente' })
  @ApiResponse({ status: 404, description: 'Imagen no encontrada' })
  async deleteImage(@Param('slug') slug: string): Promise<{ message: string }> {
    await this.deleteImageUseCase.execute(slug);
    return { message: 'Imagen eliminada exitosamente' };
  }
}
