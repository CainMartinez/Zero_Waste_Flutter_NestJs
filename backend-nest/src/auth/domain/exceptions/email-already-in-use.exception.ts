import { HttpStatus } from '@nestjs/common';
import { DomainExceptionBase } from '../../../shared/domain/domain-exception.base';

/**
 * Excepción de dominio lanzada cuando se intenta registrar
 * un usuario con un email que ya existe en la base de datos.
 */
export class EmailAlreadyInUseException extends DomainExceptionBase {
  readonly status = HttpStatus.CONFLICT; // 409
  readonly code = 'EMAIL_ALREADY_IN_USE';

  constructor(email: string) {
    super(`El correo electrónico "${email}" ya está registrado.`, { email });
  }
}