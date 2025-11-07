import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';
import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';

class AuthUseCases {
  final Future<UserSession> Function({
    required String email,
    required String password,
  }) loginUser;

  final Future<AdminSession> Function({
    required String email,
    required String password,
  }) loginAdmin;

  final Future<User> Function({
    required String email,
    required String name,
    required String password,
  }) registerUser;

  final Future<void> Function() logoutUser;
  final Future<void> Function() logoutAdmin;

  final Future<({String? accessToken, String? refreshToken, String? role})>
      Function() readStoredSession;

  AuthUseCases(AuthRepository repo)
      : loginUser = repo.loginUser,
        loginAdmin = repo.loginAdmin,
        registerUser = repo.registerUser,
        logoutUser = repo.logoutUser,
        logoutAdmin = repo.logoutAdmin,
        readStoredSession = repo.readStoredSession;
}