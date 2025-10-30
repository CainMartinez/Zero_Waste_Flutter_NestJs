import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';

/// Repositorio de Autenticación
/// No conoce DTOs ni HTTP; solo entidades y casos de uso.
abstract class AuthRepository {
  /// Login de usuario (endpoint: POST /auth/login)
  /// Devuelve la sesión (tokens + User de dominio).
  Future<UserSession> loginUser({
    required String email,
    required String password,
  });

  /// Login de admin (endpoint: POST /auth/admin/login)
  /// Devuelve la sesión (tokens + Admin de dominio).
  Future<AdminSession> loginAdmin({
    required String email,
    required String password,
  });

  /// Registro de usuario (endpoint: POST /auth/register)
  /// Devuelve el User de dominio recién creado (sin tokens).
  Future<User> registerUser({
    required String email,
    required String name,
    required String password,
  });

  /// Logout de usuario (endpoint: POST /auth/logout)
  Future<void> logoutUser({required String accessToken});

  /// Logout de admin (endpoint: POST /auth/admin/logout)
  Future<void> logoutAdmin({required String accessToken});
}