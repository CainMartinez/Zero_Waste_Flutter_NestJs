export class JwtBlacklistEntry {
  readonly jti: string;          // JWT ID (PK)
  readonly userId: number;       // FK -> users.id
  readonly token: string | null; // opcional
  readonly issuedAt: Date;       // iat
  readonly expiresAt: Date;      // exp
  readonly revokedAt: Date;      // cuándo se revocó
  readonly reason: string | null;

  constructor(props: {
    jti: string;
    userId: number;
    token: string | null;
    issuedAt: Date;
    expiresAt: Date;
    revokedAt: Date;
    reason: string | null;
  }) {
    this.jti = props.jti;
    this.userId = props.userId;
    this.token = props.token ?? null;
    this.issuedAt = props.issuedAt;
    this.expiresAt = props.expiresAt;
    this.revokedAt = props.revokedAt;
    this.reason = props.reason ?? null;
  }

  static fromPrimitives(p: {
    jti: string;
    userId: number;
    token: string | null;
    issuedAt: Date;
    expiresAt: Date;
    revokedAt: Date;
    reason: string | null;
  }): JwtBlacklistEntry {
    return new JwtBlacklistEntry({
      jti: p.jti,
      userId: p.userId,
      token: p.token ?? null,
      issuedAt: p.issuedAt,
      expiresAt: p.expiresAt,
      revokedAt: p.revokedAt,
      reason: p.reason ?? null,
    });
  }
}