import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pub_diferent/features/auth/data/datasources/auth_endpoints.dart';
import 'package:pub_diferent/features/auth/data/dto/request/register_user_request_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/register_user_response_dto.dart';

class RegisterUserRemoteException implements Exception {
  final String message;
  final int? statusCode;
  final Object? cause;

  RegisterUserRemoteException(this.message, {this.statusCode, this.cause});

  @override
  String toString() => 'RegisterUserRemoteException($statusCode): $message';
}

class RegisterUserRemoteDataSource {
  final http.Client _client;
  final Duration timeout;

  RegisterUserRemoteDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  Future<RegisterUserResponseDto> call(RegisterUserRequestDto body) async {
    final uri = AuthEndpoints.registerUser;

    try {
      final res = await _client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(body.toJson()),
          )
          .timeout(timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final map = _decode(res.body);
        return RegisterUserResponseDto.fromJson(map);
      }

      throw _buildError(res, 'Error al registrar usuario');
    } catch (e) {
      if (e is RegisterUserRemoteException) rethrow;
      throw RegisterUserRemoteException('Fallo de red al registrar usuario', cause: e);
    }
  }

  static Map<String, dynamic> _decode(String body) {
    final dynamic decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw RegisterUserRemoteException('Respuesta inesperada del servidor');
  }

  static RegisterUserRemoteException _buildError(http.Response res, String fallback) {
    try {
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'] ?? decoded['error'] ?? fallback;
        return RegisterUserRemoteException(msg.toString(), statusCode: res.statusCode);
      }
      if (decoded is List) {
        return RegisterUserRemoteException(
          decoded.map((e) => e.toString()).join(', '),
          statusCode: res.statusCode,
        );
      }
    } catch (_) {}
    return RegisterUserRemoteException(fallback, statusCode: res.statusCode);
  }
}