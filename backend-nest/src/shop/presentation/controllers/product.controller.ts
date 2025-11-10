import { Controller, Get, HttpCode, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { QueryCatalogUseCase } from '../../application/use_cases/query-catalog.usecase';
import { QueryCatalogRequestDto } from '../../application/dto/request/query-catalog.request.dto';
import { PaginatedResponseDto } from '../../application/dto/response/paginated.response.dto';
import { CatalogItemResponseDto } from '../../application/dto/response/catalog-item.response.dto';
import { AllergenResponseDto } from '../../application/dto/response/allergen.response.dto';
import { CategoryResponseDto } from '../../application/dto/response/category.response.dto';
import { CatalogAssembler } from '../assemblers/catalog.assembler';
import { AllergenOrmEntity } from '../../infrastructure/typeorm/entities-orm/allergen.orm-entity';
import { CategoryOrmEntity } from '../../infrastructure/typeorm/entities-orm/category.orm-entity';

@ApiTags('Shop')
@Controller('products')
export class ProductsController {
  constructor(
    private readonly queryCatalogUseCase: QueryCatalogUseCase,
    private readonly catalogAssembler: CatalogAssembler,
    @InjectRepository(AllergenOrmEntity)
    private readonly allergenRepository: Repository<AllergenOrmEntity>,
    @InjectRepository(CategoryOrmEntity)
    private readonly categoryRepository: Repository<CategoryOrmEntity>,
  ) {}

  @Get()
  @HttpCode(200)
  @ApiOperation({
    summary: 'Catálogo unificado de productos y menús',
    description:
      'Devuelve un catálogo paginado con productos y menús. Soporta filtrado por categoría (category), vegano (isVegan), alérgenos inverso (excludeAllergens), y ordenamiento (sortBy, sortOrder). Usa cursor pagination para scroll infinito.',
  })
  @ApiOkResponse({
    description: 'Catálogo paginado de productos y menús',
    type: PaginatedResponseDto<CatalogItemResponseDto>,
  })
  async getAll(
    @Query() filters: QueryCatalogRequestDto,
  ): Promise<PaginatedResponseDto<CatalogItemResponseDto>> {
    const result = await this.queryCatalogUseCase.execute(filters);
    return this.catalogAssembler.toPaginatedResponse(result);
  }

  @Get('allergens')
  @HttpCode(200)
  @ApiOperation({
    summary: 'Listar todos los alérgenos',
    description: 'Devuelve la lista completa de alérgenos disponibles',
  })
  @ApiOkResponse({
    description: 'Lista de alérgenos',
    type: AllergenResponseDto,
    isArray: true,
  })
  async getAllergens(): Promise<AllergenResponseDto[]> {
    const allergens = await this.allergenRepository.find({
      where: { isActive: true },
      order: { nameEs: 'ASC' },
    });

    return allergens.map((a) => ({
      code: a.code,
      nameEs: a.nameEs || a.code,
      nameEn: a.nameEn || a.code,
    }));
  }

  @Get('categories')
  @HttpCode(200)
  @ApiOperation({
    summary: 'Listar todas las categorías',
    description: 'Devuelve la lista completa de categorías disponibles',
  })
  @ApiOkResponse({
    description: 'Lista de categorías',
    type: CategoryResponseDto,
    isArray: true,
  })
  async getCategories(): Promise<CategoryResponseDto[]> {
    const categories = await this.categoryRepository.find({
      where: { isActive: true },
      order: { id: 'ASC' },
    });

    return categories.map((c) => ({
      id: c.id,
      code: c.code,
      nameEs: c.nameEs || c.code,
      nameEn: c.nameEn || c.code,
    }));
  }
}
