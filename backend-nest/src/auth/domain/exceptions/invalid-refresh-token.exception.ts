export class InvalidRefreshTokenException extends Error {
  readonly code: string;

  constructor(message = 'El refresh token es inválido o ha expirado.') {
    super(message);
    this.name = 'InvalidRefreshTokenException';
    this.code = 'INVALID_REFRESH_TOKEN';
  }
}