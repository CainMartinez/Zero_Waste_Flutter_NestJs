import { ArgumentsHost, Catch, ExceptionFilter, HttpStatus } from '@nestjs/common';
import { InvalidProductException } from '../../domain/exceptions/invalid-product.exception';

@Catch(Error)
export class DomainExceptionFilter implements ExceptionFilter {
  catch(exception: Error, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const res = ctx.getResponse();
    const req = ctx.getRequest();

    // Valores por defecto
    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let errorCode = 'INTERNAL_ERROR';
    let message = exception.message || 'Unexpected error';
    let details: Record<string, unknown> | undefined;

    // Mapeo de excepciones de dominio → HTTP
    if (exception instanceof InvalidProductException) {
      status = HttpStatus.UNPROCESSABLE_ENTITY; // 422
      errorCode = exception.code; // 'INVALID_PRODUCT'
      message = exception.message;
      details = exception.details;
    } else if (exception.name === 'ProductNotFoundException') {
      status = HttpStatus.NOT_FOUND; // 404
      errorCode = 'PRODUCT_NOT_FOUND';
    } else if (exception.name === 'InactiveProductException') {
      status = HttpStatus.BAD_REQUEST; // 400
      errorCode = 'INACTIVE_PRODUCT';
    }

    const payload = {
      statusCode: status,
      error: errorCode,
      message,
      path: req?.url,
      timestamp: new Date().toISOString(),
      ...(details ? { details } : {}),
    };

    res.status(status).json(payload);
  }
}