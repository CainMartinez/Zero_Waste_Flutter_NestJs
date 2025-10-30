import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: Registro de usuario (POST /auth/register).
/// Orquesta la llamada al repositorio y devuelve el User de dominio creado.
class RegisterUser {
  final AuthRepository _repo;

  const RegisterUser(this._repo);

  Future<User> call({
    required String email,
    required String name,
    required String password,
  }) {
    return _repo.registerUser(
      email: email,
      name: name,
      password: password,
    );
  }
}