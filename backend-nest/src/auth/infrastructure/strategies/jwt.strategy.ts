import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

/**
 * Estrategia de autenticación basada en JWT de acceso.
 * - Extrae el token de Authorization: Bearer <token>
 * - Verifica firma y claims estándar (iss, aud, exp)
 * - Expone en req.user un objeto mínimo con sub y email
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET ?? 'dev-secret-change-me',
      issuer: process.env.JWT_ISSUER ?? 'zero-waste-api',
      audience: process.env.JWT_AUDIENCE ?? 'zero-waste-clients',
    });
  }

  /**
   * El retorno de validate() se asigna a req.user.
   * Mantener payload mínimo para no sobreexponer datos.
   */
  async validate(payload: any) {
    return { sub: payload.sub, email: payload.email };
  }
}