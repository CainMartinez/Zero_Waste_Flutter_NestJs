import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';
import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';

/// Caso de uso: Login de usuario (POST /auth/login).
/// - No conoce DTOs ni HTTP.
/// - Orquesta la llamada al repositorio de dominio.
/// - Devuelve una sesión compuesta por tokens y usuario.
class LoginUser {
  final AuthRepository _repo;

  const LoginUser(this._repo);

  Future<UserSession> call({
    required String email,
    required String password,
  }) {
    return _repo.loginUser(email: email, password: password);
  }
}