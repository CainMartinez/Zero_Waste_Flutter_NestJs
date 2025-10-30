import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';

/// Caso de uso: Login de administrador (POST /auth/admin/login).
/// Orquesta la llamada al repositorio y devuelve la sesión resultante.
class LoginAdmin {
  final AuthRepository _repo;

  const LoginAdmin(this._repo);

  Future<AdminSession> call({
    required String email,
    required String password,
  }) {
    return _repo.loginAdmin(email: email, password: password);
  }
}