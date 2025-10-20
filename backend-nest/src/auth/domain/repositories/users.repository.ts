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
   * Crea y persiste un nuevo usuario.
   * @param user Entidad de dominio (ya validada y con hash aplicado)
   */
  abstract createUser(user: User): Promise<User>;
}