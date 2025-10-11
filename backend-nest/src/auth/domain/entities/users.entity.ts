export class User {
  readonly id: number;
  readonly uuid: string | null;

  readonly email: string;
  readonly name: string;

  readonly passwordHash: string;
  readonly avatarUrl: string | null;

  readonly isActive: boolean;

  readonly createdAt: Date;
  readonly updatedAt: Date;

  constructor(props: {
    id: number;
    uuid: string | null;
    email: string;
    name: string;
    passwordHash: string;
    avatarUrl: string | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }) {
    this.id = props.id;
    this.uuid = props.uuid ?? null;

    this.email = props.email;
    this.name = props.name;

    this.passwordHash = props.passwordHash;
    this.avatarUrl = props.avatarUrl ?? null;

    this.isActive = props.isActive;

    this.createdAt = props.createdAt;
    this.updatedAt = props.updatedAt;
  }

  static fromPrimitives(p: {
    id: number;
    uuid: string | null;
    email: string;
    name: string;
    passwordHash: string;
    avatarUrl: string | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  }): User {
    return new User({
      id: p.id,
      uuid: p.uuid ?? null,
      email: p.email,
      name: p.name,
      passwordHash: p.passwordHash,
      avatarUrl: p.avatarUrl ?? null,
      isActive: p.isActive,
      createdAt: p.createdAt,
      updatedAt: p.updatedAt,
    });
  }
}