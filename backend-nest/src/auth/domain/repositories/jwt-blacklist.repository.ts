import { JwtBlacklistEntry } from '../entities/blacklist.entity';

/**
 * Contrato de repositorio para la blacklist de JWT (access tokens).
 * Permite revocar tokens y consultar si un jti está invalidado.
 */
export abstract class IJwtBlacklistRepository {
  /**
   * Inserta una entrada de blacklist para un access token.
   * Si el jti ya existe, debe ser idempotente (no romper por duplicado).
   */
  abstract add(entry: JwtBlacklistEntry): Promise<void>;

  /**
   * Indica si el jti está revocado (presente en la blacklist y no expirado).
   * Se utiliza en la validación de cada request autenticada.
   */
  abstract isRevoked(jti: string): Promise<boolean>;

  /**
   * Limpia entradas expiradas para evitar crecimiento indefinido.
   * Puede ejecutarse en un job periódico (opcional).
   */
  abstract purgeExpired(now?: Date): Promise<number>;
}