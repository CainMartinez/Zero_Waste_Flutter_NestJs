import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../../auth/presentation/guards/jwt-auth.guard';
import { AdminGuard } from '../../../auth/presentation/guards/admin.guard';
import { GetAllProductsUseCase } from '../../application/use_cases/get-all-products.usecase';
import { GetProductByIdUseCase } from '../../application/use_cases/get-product-by-id.usecase';
import { CreateProductUseCase } from '../../application/use_cases/create-product.usecase';
import { UpdateProductUseCase } from '../../application/use_cases/update-product.usecase';
import { DeleteProductUseCase } from '../../application/use_cases/delete-product.usecase';
import { ReactivateProductUseCase } from '../../application/use_cases/reactivate-product.usecase';
import { ProductAdminResponseDto } from '../../application/dto/response/product-admin.response.dto';
import { CreateProductRequestDto } from '../../application/dto/request/create-product.request.dto';
import { UpdateProductRequestDto } from '../../application/dto/request/update-product.request.dto';

@ApiTags('Admin - Products')
@ApiBearerAuth()
@Controller('admin/products')
@UseGuards(JwtAuthGuard, AdminGuard)
export class ProductsAdminController {
  constructor(
    private readonly getAllProducts: GetAllProductsUseCase,
    private readonly getProductById: GetProductByIdUseCase,
    private readonly createProduct: CreateProductUseCase,
    private readonly updateProduct: UpdateProductUseCase,
    private readonly deleteProduct: DeleteProductUseCase,
    private readonly reactivateProduct: ReactivateProductUseCase,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Obtener todos los productos (incluye inactivos)' })
  @ApiOkResponse({
    description: 'Lista de productos obtenida correctamente',
    type: [ProductAdminResponseDto],
  })
  @ApiUnauthorizedResponse({ description: 'Token inválido o usuario no es admin' })
  async findAll(): Promise<ProductAdminResponseDto[]> {
    return this.getAllProducts.execute();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un producto por ID' })
  @ApiOkResponse({
    description: 'Producto obtenido correctamente',
    type: ProductAdminResponseDto,
  })
  @ApiNotFoundResponse({ description: 'Producto no encontrado' })
  @ApiUnauthorizedResponse({ description: 'Token inválido o usuario no es admin' })
  async findOne(@Param('id', ParseIntPipe) id: number): Promise<ProductAdminResponseDto> {
    return this.getProductById.execute(id);
  }

  @Post()
  @ApiOperation({ summary: 'Crear un nuevo producto' })
  @ApiCreatedResponse({
    description: 'Producto creado correctamente',
    type: ProductAdminResponseDto,
  })
  @ApiUnauthorizedResponse({ description: 'Token inválido o usuario no es admin' })
  async create(@Body() dto: CreateProductRequestDto): Promise<ProductAdminResponseDto> {
    return this.createProduct.execute(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar un producto existente' })
  @ApiOkResponse({
    description: 'Producto actualizado correctamente',
    type: ProductAdminResponseDto,
  })
  @ApiNotFoundResponse({ description: 'Producto no encontrado' })
  @ApiUnauthorizedResponse({ description: 'Token inválido o usuario no es admin' })
  async update(
    @Param('id', ParseIntPipe) id: number,
    @Body() dto: UpdateProductRequestDto,
  ): Promise<ProductAdminResponseDto> {
    return this.updateProduct.execute(id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Desactivar un producto (soft delete)' })
  @ApiNoContentResponse({ description: 'Producto desactivado correctamente' })
  @ApiNotFoundResponse({ description: 'Producto no encontrado' })
  @ApiUnauthorizedResponse({ description: 'Token inválido o usuario no es admin' })
  async remove(@Param('id', ParseIntPipe) id: number): Promise<void> {
    return this.deleteProduct.execute(id);
  }

  @Patch(':id/reactivate')
  @ApiOperation({ summary: 'Reactivar un producto desactivado' })
  @ApiOkResponse({
    description: 'Producto reactivado correctamente',
    type: ProductAdminResponseDto,
  })
  @ApiNotFoundResponse({ description: 'Producto no encontrado' })
  @ApiUnauthorizedResponse({ description: 'Token inválido o usuario no es admin' })
  async reactivate(@Param('id', ParseIntPipe) id: number): Promise<ProductAdminResponseDto> {
    return this.reactivateProduct.execute(id);
  }
}
