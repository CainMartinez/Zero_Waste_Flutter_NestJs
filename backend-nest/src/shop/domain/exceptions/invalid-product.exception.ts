import { HttpStatus } from '@nestjs/common';
import { DomainExceptionBase } from '../../../shared/domain/domain-exception.base';

/**
 * Excepción de dominio lanzada cuando un producto
 * no cumple las reglas de negocio definidas.
 *
 * Ejemplos:
 *  - Producto con precio negativo
 *  - Falta de categoría válida
 *  - Producto inactivo al intentar añadirlo a un pedido
 */
export class InvalidProductException extends DomainExceptionBase {
  readonly status = HttpStatus.UNPROCESSABLE_ENTITY; // 422
  readonly code = 'INVALID_PRODUCT';

  constructor(message: string, details?: Record<string, unknown>) {
    super(message, details);
  }
}