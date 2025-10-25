import { NestFactory } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { DomainExceptionFilter } from './shared/presentation/filters/domain-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');
  app.useGlobalFilters(new DomainExceptionFilter());
  
  const config = new DocumentBuilder()
    .setTitle('Zero Waste Pub Diferent API')
    .setDescription('Documentación interactiva de los endpoints de Zero Waste Pub Diferent.')
    .setVersion('3.5.4')
    .addBearerAuth({ type: 'http', scheme: 'bearer', bearerFormat: 'JWT' , description: 'Ingrese el access token JWT sin el "Bearer"'})
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(3000);
}
bootstrap();