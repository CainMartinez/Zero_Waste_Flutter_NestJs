import { Injectable } from '@nestjs/common';
import { User } from '../../domain/entities/users.entity';
import { UserPublicResponseDto } from '../../application/dto/response/user-public.response.dto';

/**
 * Mapea entidades de dominio a DTOs públicos para la capa de presentación.
 */
@Injectable()
export class UserPublicAssembler {
  toDto(user: User): UserPublicResponseDto {
    const dto = new UserPublicResponseDto();
    dto.id = user.id;
    dto.uuid = user.uuid ?? null;
    dto.email = user.email;
    dto.name = user.name;
    dto.avatarUrl = user.avatarUrl ?? null;
    dto.createdAt = user.createdAt;
    dto.updatedAt = user.updatedAt;
    return dto;
  }
}