import 'dart:async';
import 'package:dio/dio.dart';
import 'package:eco_bocado/core/utils/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eco_bocado/core/utils/constants.dart';

class AppServices {
  static final FlutterSecureStorage storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static final Dio dio = _buildDio();

  static Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // No sobrescribimos si ya han puesto un Authorization manual
          if (options.headers['Authorization'] != null) {
            handler.next(options);
            return;
          }

          final access = await storage.read(key: tokenKey);
          if (access != null && access.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $access';
          }

          handler.next(options);
        },
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          final req = err.requestOptions;
          final status = err.response?.statusCode;

          if (status != 401) {
            return handler.next(err);
          }

          final path = req.path;
          final isAuthCall = path.contains('/auth/login') ||
              path.contains('/auth/admin/login') ||
              path.contains('/auth/refresh');

          if (isAuthCall) {
            return handler.next(err);
          }

          // Si la sesión es de admin, no hay refresh: forzamos logout
          final role = await storage.read(key: authRoleKey);
          final isAdmin = role == 'admin';
          if (isAdmin) {
            await _clearTokens();
            return handler.next(err);
          }

          // Usuario normal: intentamos refresh
          final refreshed = await _tryRefreshToken(d);
          if (!refreshed) {
            await _clearTokens();
            return handler.next(err);
          }

          // Reintentamos la request original con el nuevo access
          final newAccess = await storage.read(key: tokenKey);
          if (newAccess != null && newAccess.isNotEmpty) {
            req.headers['Authorization'] = 'Bearer $newAccess';
          }

          final cloneResponse = await d.fetch(req);
          return handler.resolve(cloneResponse);
        },
      ),
    );

    d.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

    return d;
  }

  /// Intenta refrescar usando el refresh guardado y enviándolo por Authorization: Bearer -refresh-.
  static Future<bool> _tryRefreshToken(Dio d) async {
    final refresh = await storage.read(key: refreshKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final resp = await d.post(
        '/auth/refresh',
        options: Options(
          headers: {
            'Authorization': 'Bearer $refresh',
            'Content-Type': 'application/json',
          },
        )
      );

      if (resp.statusCode != 200) return false;

      final data = resp.data as Map<String, dynamic>?;
      final newAccess = data?['accessToken'] as String?;
      if (newAccess == null || newAccess.isEmpty) return false;

      await storage.write(key: tokenKey, value: newAccess);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _clearTokens() async {
    await storage.delete(key: tokenKey);
    await storage.delete(key: refreshKey);
    await storage.delete(key: authRoleKey);
  }
}