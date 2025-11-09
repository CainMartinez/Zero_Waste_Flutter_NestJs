import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { ImageOrmEntity } from './infrastructure/typeorm/entities-orm/image.orm-entity';
import { ImageRepositoryImpl } from './infrastructure/typeorm/repositories/image.repository.impl';
import { MinioClientService } from './infrastructure/adapters/minio-client.service';
import { UploadImageUseCase } from './application/use_cases/upload-image.usecase';
import { GetImageBySlugUseCase } from './application/use_cases/get-image-by-slug.usecase';
import { GetImagesByProductUseCase } from './application/use_cases/get-images-by-product.usecase';
import { GetImagesByMenuUseCase } from './application/use_cases/get-images-by-menu.usecase';
import { DeleteImageUseCase } from './application/use_cases/delete-image.usecase';
import { GetPresignedUrlUseCase } from './application/use_cases/get-presigned-url.usecase';
import { MediaController } from './presentation/controllers/media.controller';
import { ImageAssembler } from './presentation/assemblers/image.assembler';

@Module({
  imports: [
    TypeOrmModule.forFeature([ImageOrmEntity]),
    ConfigModule,
  ],
  controllers: [MediaController],
  providers: [
    {
      provide: 'ImageRepository',
      useClass: ImageRepositoryImpl,
    },
    MinioClientService,
    UploadImageUseCase,
    GetImageBySlugUseCase,
    GetImagesByProductUseCase,
    GetImagesByMenuUseCase,
    DeleteImageUseCase,
    GetPresignedUrlUseCase,
    ImageAssembler,
  ],
  exports: [
    UploadImageUseCase,
    GetImageBySlugUseCase,
    GetImagesByProductUseCase,
    GetImagesByMenuUseCase,
    DeleteImageUseCase,
    GetPresignedUrlUseCase,
    MinioClientService,
  ],
})
export class MediaModule {}
