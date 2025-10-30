import 'dart:convert';
import 'package:pub_diferent/features/auth/data/dto/response/user_dto.dart';

/// Representa la respuesta JSON completa del endpoint /auth/login.
class AuthUserLoginResponseDto {
  final String accessToken;
  final UserDto user;

  const AuthUserLoginResponseDto({
    required this.accessToken,
    required this.user,
  });

  factory AuthUserLoginResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthUserLoginResponseDto(
      accessToken: json['accessToken'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'user': user.toJson(),
      };

  factory AuthUserLoginResponseDto.fromJsonString(String source) =>
      AuthUserLoginResponseDto.fromJson(
        jsonDecode(source) as Map<String, dynamic>,
      );

  String toJsonString() => jsonEncode(toJson());

  AuthUserLoginResponseDto copyWith({
    String? accessToken,
    UserDto? user,
  }) {
    return AuthUserLoginResponseDto(
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
    );
  }
}