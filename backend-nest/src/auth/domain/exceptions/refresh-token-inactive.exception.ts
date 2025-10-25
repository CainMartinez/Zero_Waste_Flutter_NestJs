export class RefreshTokenInactiveException extends Error {
  readonly code: string;
  readonly jti: string;

  constructor(jti: string, message = 'El refresh token se ha revocado.') {
    super(message);
    this.name = 'RefreshTokenInactiveException';
    this.code = 'REFRESH_TOKEN_INACTIVE';
    this.jti = jti;
  }
}