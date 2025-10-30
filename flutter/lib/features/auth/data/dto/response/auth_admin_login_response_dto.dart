import 'dart:convert';
import 'package:pub_diferent/features/auth/data/dto/response/admin_dto.dart';

/// Representa la respuesta JSON completa del endpoint /auth/admin/login.
class AuthAdminLoginResponseDto {
  final String accessToken;
  final AdminDto admin;

  const AuthAdminLoginResponseDto({
    required this.accessToken,
    required this.admin,
  });

  factory AuthAdminLoginResponseDto.fromJson(Map<String, dynamic> json) {
    final adminData = {
      'email': json['email'],
      'name': json['name'],
      'avatarUrl': json['avatarUrl'],
    };

    return AuthAdminLoginResponseDto(
      accessToken: json['accessToken'] as String,
      admin: AdminDto.fromJson(adminData),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'admin': admin.toJson(),
      };

  factory AuthAdminLoginResponseDto.fromJsonString(String source) =>
      AuthAdminLoginResponseDto.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );

  String toJsonString() => jsonEncode(toJson());
}