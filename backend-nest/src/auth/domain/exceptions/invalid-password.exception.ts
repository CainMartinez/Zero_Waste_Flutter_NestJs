export class InvalidPasswordException extends Error {
  readonly code = 'INVALID_PASSWORD';

  constructor() {
    super('La contraseña introducida es incorrecta.');
    this.name = 'InvalidPasswordException';
  }
}