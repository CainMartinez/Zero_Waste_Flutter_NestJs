import { Profile } from '../entities/profile.entity';

/**
 * Contrato de acceso a perfiles.
 * Permite trabajar con perfiles de usuarios y de administradores.
 */
export abstract class IProfilesRepository {
  /**
   * Devuelve el perfil asociado a un owner (user o admin).
   */
  abstract findByOwner(ownerType: 'user' | 'admin', ownerId: number): Promise<Profile | null>;

  /**
   * Crea un nuevo perfil asociado a un owner.
   */
  abstract createForOwner(ownerType: 'user' | 'admin', ownerId: number, profile: Profile): Promise<Profile>;

  /**
   * Actualiza un perfil existente.
   */
  abstract update(profile: Profile): Promise<Profile>;
}