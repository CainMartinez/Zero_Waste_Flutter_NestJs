import { RefreshToken } from '../entities/refresh-token.entity';

/**
 * Contrato de repositorio para los refresh tokens.
 * Define las operaciones necesarias sin exponer detalles de persistencia.
 */
export abstract class IRefreshTokensRepository {
  /**
   * Persiste un nuevo refresh token o actualiza uno existente.
   * Devuelve la entidad persistida.
   */
  abstract save(token: RefreshToken): Promise<RefreshToken>;

  /**
   * Busca un token por su identificador único (JTI).
   * Devuelve null si no existe.
   */
  abstract findByJti(jti: string): Promise<RefreshToken | null>;

  /**
   * Indica si un token está activo (no revocado ni caducado).
   */
  abstract isActive(jti: string): Promise<boolean>;

  /**
   * Marca un token como revocado, sin eliminarlo de la base de datos.
   */
  abstract revokeByJti(jti: string, reason?: string): Promise<void>;

  /**
   * Indica si el usuario tiene al menos un refresh token activo.
   * Se utiliza en el flujo de /auth/refresh protegido por access token.
   */
  abstract hasActiveForUser(userId: number): Promise<boolean>;
  
  /**
   * Revoca todos los refresh tokens activos del usuario.
   * Devuelve el número de filas afectadas.
   */
  abstract revokeActiveForUser(userId: number, reason?: string): Promise<number>;
}