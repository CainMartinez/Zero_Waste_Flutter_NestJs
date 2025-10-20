import { HttpStatus } from '@nestjs/common';
import { DomainExceptionBase } from '../../../shared/domain/domain-exception.base';

/**
 * Excepción de dominio lanzada cuando la contraseña proporcionada
 * no cumple los requisitos mínimos de seguridad definidos por el negocio.
 */
export class WeakPasswordException extends DomainExceptionBase {
  readonly status = HttpStatus.BAD_REQUEST; // 400
  readonly code = 'WEAK_PASSWORD';

  constructor(details?: Record<string, unknown>) {
    super(
      'La contraseña no cumple los requisitos mínimos de seguridad.',
      details,
    );
  }
}