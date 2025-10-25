import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { IJwtBlacklistRepository } from 'src/auth/domain/repositories/jwt-blacklist.repository';

/**
 * Estrategia de autenticación basada en JWT de acceso.
 * - Extrae el token de Authorization: Bearer <token>
 * - Verifica firma y claims estándar (iss, aud, exp)
 * - Expone en req.user un objeto mínimo con sub y email
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private readonly blacklistRepo: IJwtBlacklistRepository) {
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
   * Se rechaza el acceso si el JTI del token está en blacklist.
   */
  async validate(payload: any) {
    const jti = payload?.jti;
    if (!jti) {
      throw new UnauthorizedException('Token sin identificador (jti).');
    }

    const revoked = await this.blacklistRepo.isRevoked(jti);
    if (revoked) {
      throw new UnauthorizedException('Access token revocado.');
    }

    return { sub: payload.sub, email: payload.email, jti };
  }
}