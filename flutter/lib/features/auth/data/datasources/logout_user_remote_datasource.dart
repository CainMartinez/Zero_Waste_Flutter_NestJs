import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pub_diferent/features/auth/data/datasources/auth_endpoints.dart';

/// Excepción específica del endpoint /auth/logout
class LogoutUserRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  LogoutUserRemoteException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'LogoutUserRemoteException($statusCode): $message';
}

/// Datasource exclusivo para POST /auth/logout
/// - Requiere JWT en Authorization: Bearer -token-
/// - No necesita body ni devuelve DTO
class LogoutUserRemoteDataSource {
  final http.Client _client;
  final Duration timeout;

  LogoutUserRemoteDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  /// Ejecuta el logout del usuario actual.
  /// No devuelve datos; lanza excepción si hay error HTTP o de red.
  Future<void> call({required String accessToken}) async {
    final uri = AuthEndpoints.logoutUser;

    try {
      final res = await _client
          .post(
            uri,
            headers: _authJsonHeaders(accessToken),
          )
          .timeout(timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return;
      }

      throw _buildError(res, 'Error al cerrar sesión de usuario');
    } catch (e) {
      if (e is LogoutUserRemoteException) rethrow;
      throw LogoutUserRemoteException(
        'Fallo de red al cerrar sesión de usuario',
        cause: e,
      );
    }
  }

  static Map<String, String> _authJsonHeaders(String token) => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static LogoutUserRemoteException _buildError(
    http.Response res,
    String fallback,
  ) {
    try {
      final dynamic decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? fallback;
        return LogoutUserRemoteException(
          msg.toString(),
          statusCode: res.statusCode,
        );
      }
      if (decoded is List) {
        return LogoutUserRemoteException(
          decoded.map((e) => e.toString()).join(', '),
          statusCode: res.statusCode,
        );
      }
    } catch (_) {
      // ignoramos error de parseo; devolvemos fallback
    }
    return LogoutUserRemoteException(fallback, statusCode: res.statusCode);
  }
}