# Pub Diferent · Nest JS
> Este readme se irá actualizando a medida que la aplicación vaya creciendo, se centrará solamente en la parte técnica de Nest JS.

## 1. Media Module - Gestión de Imágenes con MinIO

Este módulo maneja la subida, almacenamiento y gestión de imágenes para productos y menús usando MinIO como almacenamiento de objetos.

## 🚀 Características

- ✅ Subida de imágenes a MinIO con validación de tipo y tamaño
- ✅ Almacenamiento de metadatos en base de datos MySQL
- ✅ Buckets separados para productos y menús
- ✅ Slugs únicos para identificación de imágenes (formato: `{bucket}-{timestamp}-{nombre}`)
- ✅ Paths relativos en BD para escalabilidad (`/images/products/file.jpg`)
- ✅ Relaciones directas con productos y menús (Foreign Keys)
- ✅ URLs públicas y pre-firmadas
- ✅ Soft delete (las imágenes se marcan como inactivas pero se conservan)
- ✅ Arquitectura limpia (Domain, Application, Infrastructure, Presentation)
- ✅ Documentación Swagger automática

## 📦 Instalación

### 1. Variables de entorno

Agrega estas variables a tu archivo `.env`:

```env
# MinIO Configuration
MINIO_ENDPOINT=localhost
MINIO_PORT=9000
MINIO_USE_SSL=false
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_PUBLIC_URL=http://localhost:9000
```

### 2. Docker Compose

MinIO ya está configurado en el `docker-compose.yml`. Levanta los servicios:

```bash
docker-compose up -d
```

MinIO estará disponible en:
- API: `http://localhost:9000`
- Console: `http://localhost:9001` (usuario: minioadmin, contraseña: minioadmin)

### 3. Base de datos

La tabla `images` se creará automáticamente con TypeORM synchronize.

## 📚 API Endpoints

### 1. Subir una imagen

```http
POST /media/upload
Content-Type: multipart/form-data

Parámetros:
- file: archivo de imagen (JPEG, PNG, WEBP)
- productId: (opcional) ID del producto
- menuId: (opcional) ID del menú
```

**Ejemplo con cURL (imagen de producto):**
```bash
curl -X POST http://localhost:8080/media/upload \
  -F "file=@/path/to/image.jpg" \
  -F "productId=1"
```

**Ejemplo (imagen de menú):**
```bash
curl -X POST http://localhost:8080/media/upload \
  -F "file=@/path/to/menu.jpg" \
  -F "menuId=5"
```

**Respuesta:**
```json
{
  "id": 1,
  "slug": "products-1699401234567-product-image.jpg",
  "fileName": "1699401234567-product-image.jpg",
  "path": "/images/products/1699401234567-product-image.jpg",
  "url": "http://localhost:9000/images/products/1699401234567-product-image.jpg",
  "mimeType": "image/jpeg",
  "size": 245678,
  "productId": 1,
  "menuId": null,
  "isActive": true,
  "createdAt": "2024-11-08T10:30:00Z",
  "updatedAt": "2024-11-08T10:30:00Z"
}
```

### 2. Obtener imagen por slug

```http
GET /media/slug/:slug
```

**Ejemplo:**
```bash
curl http://localhost:8080/media/slug/products-1699401234567-product-image.jpg
```

### 3. Obtener imágenes de un producto

```http
GET /media/product/:productId
```

**Ejemplo:**
```bash
curl http://localhost:8080/media/product/1
```

### 4. Obtener imágenes de un menú

```http
GET /media/menu/:menuId
```

**Ejemplo:**
```bash
curl http://localhost:8080/media/menu/5
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "slug": "products-1699401234567-product-image.jpg",
    "fileName": "1699401234567-product-image.jpg",
    "path": "/images/products/1699401234567-product-image.jpg",
    "url": "http://localhost:9000/images/products/1699401234567-product-image.jpg",
    "mimeType": "image/jpeg",
    "size": 245678,
    "productId": 1,
    "menuId": null,
    "isActive": true,
    "createdAt": "2024-11-08T10:30:00Z",
    "updatedAt": "2024-11-08T10:30:00Z"
  }
]
```

### 5. Obtener URL pre-firmada

```http
GET /media/slug/:slug/presigned-url
```

Genera una URL válida por 7 días.

**Ejemplo:**
```bash
curl http://localhost:8080/media/slug/products-1699401234567-product-image.jpg/presigned-url
```

**Respuesta:**
```json
{
  "url": "http://localhost:9000/products/1699401234567-product-image.jpg?X-Amz-Algorithm=..."
}
```

### 6. Eliminar imagen

```http
DELETE /media/slug/:slug
```

**Ejemplo:**
```bash
curl -X DELETE http://localhost:8080/media/slug/products-1699401234567-product-image.jpg
```

## 🏗️ Arquitectura (Clean Architecture)

```
media/
├── domain/                           # Capa de dominio (lógica de negocio)
│   ├── entities/
│   │   └── image.entity.ts          # Entidad de dominio Image + enum ImageType
│   └── repositories/
│       └── image.repository.ts      # Interfaz del repositorio
│
├── application/                      # Capa de aplicación (casos de uso)
│   ├── dto/
│   │   ├── request/
│   │   │   └── upload-image.request.dto.ts   # DTO de entrada
│   │   └── response/
│   │       └── image.response.dto.ts         # DTO de salida
│   └── use_cases/
│       ├── upload-image.usecase.ts              # Subir imagen
│       ├── get-image-by-slug.usecase.ts         # Obtener por slug
│       ├── get-images-by-product.usecase.ts     # Obtener por producto
│       ├── get-images-by-menu.usecase.ts        # Obtener por menú
│       ├── delete-image.usecase.ts              # Eliminar imagen
│       └── get-presigned-url.usecase.ts         # URL pre-firmada
│
├── infrastructure/                   # Capa de infraestructura (persistencia)
│   ├── typeorm/
│   │   ├── entities-orm/
│   │   │   └── image.orm-entity.ts  # Entidad TypeORM
│   │   └── repositories/
│   │       └── image.repository.impl.ts # Implementación repositorio
│   └── adapters/
│       └── minio-client.service.ts  # Cliente MinIO (S3-compatible)
│
├── presentation/                     # Capa de presentación (API REST)
│   ├── controllers/
│   │   └── media.controller.ts      # Endpoints HTTP
│   └── assemblers/
│       └── image.assembler.ts       # Convierte entidades a DTOs
│
└── media.module.ts                   # Módulo NestJS
```

## 🔐 Validaciones

- **Tipos de archivo permitidos:** JPEG, JPG, PNG, WEBP
- **Tamaño máximo:** 5 MB
- **Asociación:** Solo se puede asociar una imagen a un producto O a un menú (no ambos)

## 📊 Base de Datos

### Tabla `images`

| Campo       | Tipo         | Descripción                                     |
|-------------|--------------|-------------------------------------------------|
| id          | INT          | ID autoincremental                              |
| slug        | VARCHAR(255) | Identificador único (bucket-timestamp-nombre)   |
| file_name   | VARCHAR(255) | Nombre del archivo en MinIO                     |
| path        | VARCHAR(500) | Ruta relativa (/images/products/file.jpg)       |
| mime_type   | VARCHAR(100) | Tipo MIME (image/jpeg, etc.)                    |
| size        | INT          | Tamaño en bytes                                 |
| product_id  | INT          | FK a products.id (nullable)                     |
| menu_id     | INT          | FK a rescue_menus.id (nullable)                 |
| is_active   | TINYINT      | 1 = activo, 0 = eliminado (soft)                |
| created_at  | TIMESTAMP    | Fecha de creación                               |
| updated_at  | TIMESTAMP    | Fecha de actualización                          |

**Índices:**
- `idx_slug` (slug) - UNIQUE
- `idx_product_id` (product_id)
- `idx_menu_id` (menu_id)

**Foreign Keys:**
- `fk_images_product`: product_id → products.id (ON DELETE CASCADE)
- `fk_images_menu`: menu_id → rescue_menus.id (ON DELETE CASCADE)

## 🧪 Uso desde otros módulos

```typescript
import { UploadImageUseCase } from './media/application/use_cases/upload-image.usecase';
import { GetImagesByProductUseCase } from './media/application/use_cases/get-images-by-product.usecase';
import { GetImagesByMenuUseCase } from './media/application/use_cases/get-images-by-menu.usecase';
import { DeleteImageUseCase } from './media/application/use_cases/delete-image.usecase';

// En tu módulo, importa MediaModule
@Module({
  imports: [MediaModule],
  // ...
})

// En tu servicio, inyecta los casos de uso que necesites
constructor(
  private readonly uploadImageUseCase: UploadImageUseCase,
  private readonly getImagesByProductUseCase: GetImagesByProductUseCase,
  private readonly getImagesByMenuUseCase: GetImagesByMenuUseCase,
  private readonly deleteImageUseCase: DeleteImageUseCase,
) {}

// Subir imagen de producto
const image = await this.uploadImageUseCase.execute(file, productId, undefined);

// Subir imagen de menú
const menuImage = await this.uploadImageUseCase.execute(file, undefined, menuId);

// Obtener imágenes de un producto
const images = await this.getImagesByProductUseCase.execute(productId);

// Obtener imágenes de un menú
const menuImages = await this.getImagesByMenuUseCase.execute(menuId);

// Eliminar imagen por slug
await this.deleteImageUseCase.execute(imageSlug);
```

## 🎯 Próximos pasos

1. Implementar relación OneToMany bidireccional entre Product/Menu e Images
2. Agregar endpoint para reordenar imágenes (campo position/order)
3. Implementar compresión/optimización de imágenes con Sharp
4. Agregar generación de thumbnails automática
4. Implementar redimensionamiento automático de imágenes
5. Agregar watermark opcional a las imágenes

## 📝 Notas

- Las imágenes se eliminan mediante soft delete (is_active = false)
- Los buckets se crean automáticamente al iniciar la aplicación
- La política de los buckets permite acceso público de lectura
- Las URLs públicas son permanentes mientras el archivo exista
- Las URLs pre-firmadas expiran en 7 días por defecto