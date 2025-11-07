import { Injectable, NotFoundException } from '@nestjs/common';
import { IUsersRepository } from '../../domain/repositories/users.repository';
import { PasswordHasherService } from '../../infrastructure/crypto/password-hasher.service';
import { InvalidPasswordException } from '../../domain/exceptions/invalid-password.exception';
import { User } from '../../domain/entities/users.entity';

@Injectable()
export class ChangePasswordUseCase {
  constructor(
    private readonly usersRepo: IUsersRepository,
    private readonly passwordHasher: PasswordHasherService,
  ) {}

  async execute(email: string, currentPassword: string, newPassword: string): Promise<void> {
    if (!email) {
      throw new NotFoundException('No se pudo determinar el email del usuario autenticado.');
    }

    const user = await this.usersRepo.findByEmail(email.toLowerCase());
    if (!user) {
      throw new NotFoundException('Usuario no encontrado.');
    }

    // Verificar contraseña actual
    const isValidCurrent = await this.passwordHasher.verify(user.passwordHash, currentPassword);
    if (!isValidCurrent) {
      throw new InvalidPasswordException();
    }

    // Hashear nueva contraseña y crear entidad actualizada
    const newPasswordHash = await this.passwordHasher.hash(newPassword);
    const updatedUser = new User({
      ...user,
      passwordHash: newPasswordHash,
      updatedAt: new Date(),
    });

    await this.usersRepo.updateUser(updatedUser);
  }
}
