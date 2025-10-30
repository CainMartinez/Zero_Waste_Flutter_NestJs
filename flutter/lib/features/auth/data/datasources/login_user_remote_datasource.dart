import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pub_diferent/features/auth/data/datasources/auth_endpoints.dart';
import 'package:pub_diferent/features/auth/data/dto/request/login_request_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/auth_user_login_response_dto.dart';

/// Excepción específica de red para el endpoint /auth/login
class LoginUserRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  LoginUserRemoteException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'LoginUserRemoteException($statusCode): $message';
}

/// Datasource exclusivo para el endpoint POST /auth/login
class LoginUserRemoteDataSource {
  final http.Client _client;
  final Duration timeout;

  LoginUserRemoteDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  Future<AuthUserLoginResponseDto> call(LoginRequestDto body) async {
    final uri = AuthEndpoints.loginUser;

    try {
      final res = await _client
          .post(
            uri,
            headers: _jsonHeaders(),
            body: jsonEncode(body.toJson()),
          )
          .timeout(timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = _decode(res.body);
        return AuthUserLoginResponseDto.fromJson(map);
      }

      throw _buildError(res, 'Error al iniciar sesión');
    } catch (e) {
      if (e is LoginUserRemoteException) rethrow;
      throw LoginUserRemoteException('Fallo de red al iniciar sesión', cause: e);
    }
  }

  static Map<String, String> _jsonHeaders() => const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  static Map<String, dynamic> _decode(String body) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw LoginUserRemoteException('Respuesta inesperada del servidor');
  }

  static LoginUserRemoteException _buildError(http.Response res, String fallback) {
    try {
      final dynamic decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? fallback;
        return LoginUserRemoteException(msg.toString(), statusCode: res.statusCode);
      }
      if (decoded is List) {
        return LoginUserRemoteException(
          decoded.map((e) => e.toString()).join(', '),
          statusCode: res.statusCode,
        );
      }
    } catch (_) {
      // ignoramos parse error y devolvemos genérico
    }
    return LoginUserRemoteException(fallback, statusCode: res.statusCode);
  }
}