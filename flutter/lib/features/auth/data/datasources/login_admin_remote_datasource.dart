import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pub_diferent/features/auth/data/datasources/auth_endpoints.dart';
import 'package:pub_diferent/features/auth/data/dto/request/admin_login_request_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/auth_admin_login_response_dto.dart';

/// Excepción específica del endpoint /auth/admin/login
class AdminLoginRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  AdminLoginRemoteException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'AdminLoginRemoteException($statusCode): $message';
}

/// Datasource exclusivo para POST /auth/admin/login
class AdminLoginRemoteDataSource {
  final http.Client _client;
  final Duration timeout;

  AdminLoginRemoteDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  Future<AuthAdminLoginResponseDto> call(AdminLoginRequestDto body) async {
    final uri = AuthEndpoints.loginAdmin;

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
        return AuthAdminLoginResponseDto.fromJson(map);
      }

      throw _buildError(res, 'Error al iniciar sesión de administrador');
    } catch (e) {
      if (e is AdminLoginRemoteException) rethrow;
      throw AdminLoginRemoteException(
        'Fallo de red al iniciar sesión de administrador',
        cause: e,
      );
    }
  }

  static Map<String, String> _jsonHeaders() => const {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  static Map<String, dynamic> _decode(String body) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw AdminLoginRemoteException('Respuesta inesperada del servidor');
  }

  static AdminLoginRemoteException _buildError(
    http.Response res,
    String fallback,
  ) {
    try {
      final dynamic decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? fallback;
        return AdminLoginRemoteException(
          msg.toString(),
          statusCode: res.statusCode,
        );
      }
      if (decoded is List) {
        return AdminLoginRemoteException(
          decoded.map((e) => e.toString()).join(', '),
          statusCode: res.statusCode,
        );
      }
    } catch (_) {
      // ignoramos error de parseo y devolvemos mensaje genérico
    }
    return AdminLoginRemoteException(fallback, statusCode: res.statusCode);
  }
}