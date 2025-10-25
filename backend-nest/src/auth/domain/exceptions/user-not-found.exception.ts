export class UserNotFoundException extends Error {
  readonly code = 'USER_NOT_FOUND';

  constructor(email: string) {
    super(`No existe un usuario con el email: ${email}`);
    this.name = 'UserNotFoundException';
  }
}