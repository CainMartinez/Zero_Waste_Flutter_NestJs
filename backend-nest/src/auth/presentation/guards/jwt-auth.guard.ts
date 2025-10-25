import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

/**
 * Guard para proteger endpoints que requieren un access token válido.
 */
@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {}