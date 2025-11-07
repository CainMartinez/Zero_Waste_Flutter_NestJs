import { Injectable } from '@nestjs/common';
import { Admin } from '../../domain/entities/admins.entity';
import { AdminLoginResponseDto } from '../../application/dto/response/admin-login.response.dto';

/**
 * Transforma la entidad de dominio Admin en un DTO público.
 */
@Injectable()
export class AdminPublicAssembler {
  toDto(admin: Admin, accessToken: string): AdminLoginResponseDto {
    const dto = new AdminLoginResponseDto();
    dto.accessToken = accessToken;
    dto.email = admin.email;
    dto.name = admin.name;
    dto.avatarUrl = admin.avatarUrl;
    dto.role = 'admin';
    return dto;
  }
}