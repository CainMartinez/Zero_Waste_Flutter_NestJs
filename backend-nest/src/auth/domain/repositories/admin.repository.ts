import { Admin } from '../entities/admins.entity';

/**
 * Contrato de repositorio para la entidad Admin.
 * Define las operaciones disponibles sin exponer infraestructura.
 */
export abstract class IAdminsRepository {
  /**
   * Busca un administrador por su email.
   * Devuelve la entidad de dominio o null si no existe.
   */
  abstract findByEmail(email: string): Promise<Admin | null>;

  /**
   * Actualiza un administrador existente.
   */
  abstract updateAdmin(admin: Admin): Promise<Admin>;
}