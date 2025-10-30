import 'dart:convert';
import 'package:pub_diferent/features/auth/data/dto/response/user_dto.dart';

/// DTO de respuesta del endpoint POST /auth/register
class RegisterUserResponseDto {
  final UserDto user;

  const RegisterUserResponseDto({required this.user});

  factory RegisterUserResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterUserResponseDto(
      user: UserDto.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() => user.toJson();

  factory RegisterUserResponseDto.fromJsonString(String source) =>
      RegisterUserResponseDto.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );

  String toJsonString() => jsonEncode(toJson());

  String successMessage() => 'Te has registrado con éxito, ${user.name}.';
}