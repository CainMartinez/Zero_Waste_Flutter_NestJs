import { ApiProperty } from '@nestjs/swagger';

/**
 * Respuesta del endpoint /auth/admin/login
 * Contiene el access token y los datos públicos del administrador.
 */
export class AdminLoginResponseDto {
  @ApiProperty({
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    description: 'Access token JWT del administrador autenticado',
  })
  accessToken!: string;

  @ApiProperty({ example: 'admin@pubdiferent.com' })
  email!: string;

  @ApiProperty({ example: 'Administrador General' })
  name!: string;

  @ApiProperty({
    example: 'https://i.pravatar.cc/300?img=name',
    nullable: true,
  })
  avatarUrl!: string | null;
}