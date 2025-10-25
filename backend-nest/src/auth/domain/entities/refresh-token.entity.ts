export class RefreshToken {
  readonly id?: number;
  readonly userId: number;
  readonly jti: string;
  readonly expiresAt: Date;
  readonly createdAt: Date;
  readonly revokedAt: Date | null;
  readonly reason: string | null;

  constructor(props: {
    id?: number;
    userId: number;
    jti: string;
    expiresAt: Date;
    createdAt?: Date;
    revokedAt?: Date | null;
    reason?: string | null;
  }) {
    this.id = props.id;
    this.userId = props.userId;
    this.jti = props.jti;
    this.expiresAt = props.expiresAt;
    this.createdAt = props.createdAt ?? new Date();
    this.revokedAt = props.revokedAt ?? null;
    this.reason = props.reason ?? null;
  }

  /** Devuelve true si el token sigue activo (no revocado ni caducado). */
  get isActive(): boolean {
    const now = new Date();
    return !this.revokedAt && this.expiresAt > now;
  }

  /** Marca el token como revocado (logout, rotación, etc.). */
  revoke(reason: string = 'revoked'): RefreshToken {
    return new RefreshToken({
      ...this,
      revokedAt: new Date(),
      reason,
    });
  }
}