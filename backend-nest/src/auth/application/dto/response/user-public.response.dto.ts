import { ApiProperty } from '@nestjs/swagger';

/**
 * Datos públicos del usuario para respuestas de Auth (p. ej., /auth/register).
 * No incluye información sensible (password_hash, flags internos, etc.).
 */
export class UserPublicResponseDto {
  @ApiProperty({ example: 1, description: 'ID interno autoincremental.' })
  id!: number;

  @ApiProperty({
    example: '7f1b8c7a-8b20-4c4b-9d9d-1c2b3a4d5e6f',
    description: 'Identificador público (uuid).',
    nullable: true,
  })
  uuid!: string | null;

  @ApiProperty({
    example: 'usuario@example.com',
    description: 'Email del usuario.',
  })
  email!: string;

  @ApiProperty({
    example: 'María Gómez',
    description: 'Nombre visible del usuario.',
  })
  name!: string;

  @ApiProperty({
    example: 'https://cdn.example.com/avatars/u123.png',
    description: 'URL del avatar (opcional).',
    nullable: true,
  })
  avatarUrl!: string | null;

  @ApiProperty({ example: 'Rol de usuario' })
  role!: string;

  @ApiProperty({ 
    example: true,
    description: 'Indica si el usuario está activo.',
  })
  isActive!: boolean;

  @ApiProperty({
    example: '2025-10-16T03:25:41.000Z',
    description: 'Fecha de creación.',
  })
  createdAt!: Date;

  @ApiProperty({
    example: '2025-10-16T03:25:41.000Z',
    description: 'Fecha de última actualización.',
  })
  updatedAt!: Date;
}