import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: Logout de administrador (POST /auth/admin/logout).
/// No conoce HTTP ni DTOs; delega en el repositorio.
/// Requiere el accessToken actual para autorizar la operación.
class LogoutAdmin {
  final AuthRepository _repo;

  const LogoutAdmin(this._repo);

  Future<void> call({required String accessToken}) {
    return _repo.logoutAdmin(accessToken: accessToken);
  }
}