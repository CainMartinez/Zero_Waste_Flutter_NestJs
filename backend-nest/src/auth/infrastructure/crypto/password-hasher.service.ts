import { Injectable } from '@nestjs/common';
import * as argon2 from 'argon2';

/**
 * Servicio de hashing de contraseñas.
 * - Usa Argon2id (recomendado para contraseñas).
 * - Expone `hash` y `verify`.
 */
@Injectable()
export class PasswordHasherService {
  /**
   * Genera el hash de una contraseña en texto claro.
   */
  async hash(plain: string): Promise<string> {
    // Parámetros razonables para entorno de servidor (ajusta según recursos)
    return argon2.hash(plain, {
      type: argon2.argon2id,
      memoryCost: 2 ** 16, // 64 MB
      timeCost: 3,         // iteraciones
      parallelism: 1,
    });
    // Nota: el salt lo gestiona argon2 internamente (aleatorio y embebido).
  }

  /**
   * Verifica una contraseña comparándola con su hash.
   */
  async verify(hash: string, plain: string): Promise<boolean> {
    try {
      return await argon2.verify(hash, plain);
    } catch {
      return false;
    }
  }
}