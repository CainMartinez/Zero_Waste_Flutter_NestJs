import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Matches, MinLength } from 'class-validator';

export class ChangePasswordRequestDto {
  @ApiProperty({
    description: 'Contraseña actual del usuario',
    example: 'C0ntr4seña_Segura',
  })
  @IsNotEmpty()
  @IsString()
  currentPassword: string;

  @ApiProperty({
    description: 'Nueva contraseña (mínimo 8 caracteres, 1 mayúscula, 1 número)',
    example: 'Password1!',
  })
  @IsNotEmpty()
  @IsString()
  @MinLength(8, { message: 'La contraseña debe tener al menos 8 caracteres' })
  @Matches(/(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}/, {
    message: 'La contraseña debe contener al menos 8 caracteres, una mayúscula y un número',
  })
  newPassword: string;
}
