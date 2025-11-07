import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';

abstract class AuthRepository {
  Future<UserSession> loginUser({
    required String email,
    required String password,
  });

  Future<AdminSession> loginAdmin({
    required String email,
    required String password,
  });

  Future<User> registerUser({
    required String email,
    required String name,
    required String password,
  });

  Future<void> logoutUser();

  Future<void> logoutAdmin();

  Future<({String? accessToken, String? refreshToken, String? role})>
      readStoredSession();
}