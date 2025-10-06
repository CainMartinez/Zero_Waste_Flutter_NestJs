import { Controller, Get, HttpCode } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { ListProductsUseCase } from '../../application/use_cases/list-products.usecase';
import { ProductResponseDto } from '../../application/dto/product.response.dto';

@ApiTags('Shop - Products')
@Controller('products')
export class ProductsController {
  constructor(private readonly listProductsUseCase: ListProductsUseCase) {}

  @Get()
  @HttpCode(200)
  @ApiOperation({
    summary: 'Listar productos',
    description:
      'Devuelve el catálogo completo de productos visibles en el shop.',
  })
  @ApiOkResponse({
    description: 'Listado de productos disponibles',
    type: ProductResponseDto,
    isArray: true,
  })
  async getAll(): Promise<ProductResponseDto[]> {
    return this.listProductsUseCase.execute();
  }
}
