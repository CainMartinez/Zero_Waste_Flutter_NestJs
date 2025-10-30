import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pub_diferent/features/auth/data/datasources/auth_endpoints.dart';

/// Excepción específica del endpoint /auth/admin/logout
class LogoutAdminRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  LogoutAdminRemoteException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'LogoutAdminRemoteException($statusCode): $message';
}

/// Datasource exclusivo para POST /auth/admin/logout
/// - Requiere JWT en Authorization: Bearer -token-
/// - No necesita body ni devuelve DTO
class LogoutAdminRemoteDataSource {
  final http.Client _client;
  final Duration timeout;

  LogoutAdminRemoteDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  /// Ejecuta el logout del administrador actual.
  /// No devuelve datos; lanza excepción si hay error HTTP o de red.
  Future<void> call({required String accessToken}) async {
    final uri = AuthEndpoints.logoutAdmin;

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

      throw _buildError(res, 'Error al cerrar sesión de administrador');
    } catch (e) {
      if (e is LogoutAdminRemoteException) rethrow;
      throw LogoutAdminRemoteException(
        'Fallo de red al cerrar sesión de administrador',
        cause: e,
      );
    }
  }

  static Map<String, String> _authJsonHeaders(String token) => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static LogoutAdminRemoteException _buildError(
    http.Response res,
    String fallback,
  ) {
    try {
      final dynamic decoded = jsonDecode(res.body);

      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? fallback;
        return LogoutAdminRemoteException(
          msg.toString(),
          statusCode: res.statusCode,
        );
      }
      if (decoded is List) {
        return LogoutAdminRemoteException(
          decoded.map((e) => e.toString()).join(', '),
          statusCode: res.statusCode,
        );
      }
    } catch (_) {
      // Ignoramos error de parseo; devolvemos mensaje genérico
    }
    return LogoutAdminRemoteException(fallback, statusCode: res.statusCode);
  }
}