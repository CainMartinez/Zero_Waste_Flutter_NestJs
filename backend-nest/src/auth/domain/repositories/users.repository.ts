import { User } from '../entities/users.entity';

/**
 * Interfaz de repositorio para entidades de usuario.
 * Define las operaciones necesarias desde el dominio.
 */
export abstract class IUsersRepository {
  /**
   * Comprueba si ya existe un usuario con el email indicado.
   */
  abstract existsByEmail(email: string): Promise<boolean>;

  /**
   * Devuelve el usuario por email o null si no existe.
   * Necesario para el flujo de login (verificación de credenciales).
   */
  abstract findByEmail(email: string): Promise<User | null>;

  /**
   * Crea y persiste un nuevo usuario.
   * @param user Entidad de dominio (ya validada y con hash aplicado)
   */
  abstract createUser(user: User): Promise<User>;

  /**
   * Actualiza un usuario existente.
   */
  abstract updateUser(user: User): Promise<User>;
}