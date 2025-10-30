import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: Logout de usuario (POST /auth/logout).
/// No conoce HTTP ni DTOs; delega en el repositorio.
/// Requiere el accessToken actual para autorizar la operación.
class LogoutUser {
  final AuthRepository _repo;

  const LogoutUser(this._repo);

  Future<void> call({required String accessToken}) {
    return _repo.logoutUser(accessToken: accessToken);
  }
}