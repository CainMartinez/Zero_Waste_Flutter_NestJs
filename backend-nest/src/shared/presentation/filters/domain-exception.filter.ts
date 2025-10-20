import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { DomainExceptionBase } from '../../domain/domain-exception.base';

// Opcional: TypeORM error typing
type AnyObj = Record<string, any>;

@Catch()
export class DomainExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx   = host.switchToHttp();
    const res   = ctx.getResponse();
    const req   = ctx.getRequest();
    const now   = new Date().toISOString();

    // 1) Excepciones de dominio (todas pasan por aquí, sin if/else por tipo)
    if (this.isDomainException(exception)) {
      const payload = {
        statusCode: exception.status,
        error: exception.code,
        message: exception.message,
        path: req?.url,
        timestamp: now,
        ...(exception.details ? { details: exception.details } : {}),
      };
      return res.status(exception.status).json(payload);
    }

    // 2) HttpException de Nest (BadRequestException, NotFoundException, etc.)
    if (exception instanceof HttpException) {
      const status  = exception.getStatus();
      const resp    = exception.getResponse();
      const message = typeof resp === 'string' ? resp : (resp as AnyObj)?.message ?? exception.message;

      const payload = {
        statusCode: status,
        error: (resp as AnyObj)?.error ?? HttpStatus[status],
        message,
        path: req?.url,
        timestamp: now,
      };
      return res.status(status).json(payload);
    }

    // 3) (Opcional) Errores infra comunes (TypeORM / MariaDB) → mapeo genérico
    const ormStatus = this.tryMapOrmErrorToHttp(exception as AnyObj);
    if (ormStatus) {
      const payload = {
        statusCode: ormStatus.status,
        error: ormStatus.code,
        message: ormStatus.message,
        path: req?.url,
        timestamp: now,
      };
      return res.status(ormStatus.status).json(payload);
    }

    // 4) Fallback: 500
    const payload = {
      statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
      error: 'INTERNAL_ERROR',
      message: (exception as Error)?.message ?? 'Unexpected error',
      path: req?.url,
      timestamp: now,
    };
    return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json(payload);
  }

  // -------- helpers --------
  private isDomainException(e: any): e is DomainExceptionBase {
    return e && typeof e === 'object' && 'status' in e && 'code' in e && 'message' in e;
  }

  private tryMapOrmErrorToHttp(e: AnyObj):
    | { status: number; code: string; message: string }
    | null {
    // MySQL/MariaDB duplicate key
    if (e?.code === 'ER_DUP_ENTRY') {
      return { status: 409, code: 'DUPLICATE_KEY', message: 'Recurso duplicado' };
    }
    return null;
  }
}