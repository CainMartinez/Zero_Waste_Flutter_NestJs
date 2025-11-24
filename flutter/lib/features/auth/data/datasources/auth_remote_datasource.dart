import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eco_bocado/core/utils/app_services.dart';

/// Datasource REMOTO para AUTH
class AuthRemoteDataSource {
  const AuthRemoteDataSource();

  /// POST /auth/login (usuarios)
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final Response res = await AppServices.dio.post(
        '/auth/login',
        data: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Extraer mensaje del backend si existe
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? 'Error en login';
        throw Exception(message);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/admin/login
  Future<Map<String, dynamic>> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final Response res = await AppServices.dio.post(
        '/auth/admin/login',
        data: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Extraer mensaje del backend si existe
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? 'Error en login admin';
        throw Exception(message);
      }
      throw Exception('Error de conexión: ${e.message}');
    }
  }

  /// POST /auth/register
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final Response res = await AppServices.dio.post(
        '/auth/register',
        data: jsonEncode({
          'email': email.trim(),
          'name': name.trim(),
          'password': password,
        }),
      );

      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Extraer mensaje del backend si existe
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['error'] ?? 'Error en registro';
        throw Exception(message);
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      // Capturar cualquier otro error
      throw Exception('Error inesperado: $e');
    }
  }

  /// POST /auth/logout (usuario)
  Future<void> logoutUser() async {
    await AppServices.dio.post('/auth/logout');
  }

  /// POST /auth/admin/logout
  Future<void> logoutAdmin() async {
    await AppServices.dio.post('/auth/admin/logout');
  }

  /// POST /auth/refresh
  Future<Map<String, dynamic>> refreshAccessToken({
    required String refreshToken,
  }) async {
    final Response res = await AppServices.dio.post(
      '/auth/refresh',
      options: Options(
        headers: {
          'Authorization': 'Bearer $refreshToken',
        },
      ),
    );

    if (res.statusCode == null || res.statusCode! >= 400) {
      throw Exception('Error en /auth/refresh: ${res.data}');
    }

    return res.data as Map<String, dynamic>;
  }
}