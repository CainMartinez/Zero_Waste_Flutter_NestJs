import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';

/**
 * Guard para proteger endpoints que solo pueden ser accedidos por administradores.
 * Debe usarse después de JwtAuthGuard.
 */
@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Usuario no autenticado');
    }

    if (user.ownerType !== 'admin') {
      throw new ForbiddenException('Acceso denegado: se requieren permisos de administrador');
    }

    return true;
  }
}
