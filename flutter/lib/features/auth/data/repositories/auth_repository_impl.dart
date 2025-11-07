import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';
import 'package:pub_diferent/features/auth/domain/entities/auth_tokens.dart';
import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin.dart';
import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';

import 'package:pub_diferent/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  const AuthRepositoryImpl(
    this._remote,
    this._local,
  );

  @override
  Future<UserSession> loginUser({
    required String email,
    required String password,
  }) async {
    // Backend
    final data = await _remote.loginUser(email: email, password: password);
    final access = data['accessToken'] as String;
    final refresh = data['refreshToken'] as String?;
    final u = data['user'] as Map<String, dynamic>;

    // Map a dominio
    final user = User(
      id: u['id'] as int,
      uuid: u['uuid'] as String?,
      email: u['email'] as String,
      name: u['name'] as String,
      avatarUrl: u['avatarUrl'] as String?,
      isActive: u['isActive'] as bool?,
      createdAt: u['createdAt'] != null 
          ? (u['createdAt'] is String 
              ? DateTime.tryParse(u['createdAt'] as String)
              : u['createdAt'] as DateTime?)
          : null,
      updatedAt: u['updatedAt'] != null
          ? (u['updatedAt'] is String
              ? DateTime.tryParse(u['updatedAt'] as String)
              : u['updatedAt'] as DateTime?)
          : null,
    );

    // Persistencia local (tokens + identidad + role=user)
    await _local.saveUserSession(
      accessToken: access,
      refreshToken: refresh,
      role: 'user',
      name: user.name,
      email: user.email,
      avatarUrl: user.avatarUrl,
    );

    return UserSession(
      tokens: AuthTokens(accessToken: access, refreshToken: refresh),
      user: user,
    );
  }

  @override
  Future<AdminSession> loginAdmin({
    required String email,
    required String password,
  }) async {
    // Backend
    final data = await _remote.loginAdmin(email: email, password: password);
    final access = data['accessToken'] as String;

    // Map a dominio - el admin login devuelve los datos en el root, no en un objeto anidado
    final admin = Admin(
      id: null, // El backend no devuelve el ID en admin login
      uuid: null,
      email: data['email'] as String,
      name: data['name'] as String,
      avatarUrl: data['avatarUrl'] as String?,
      isActive: true,
      createdAt: null,
      updatedAt: null,
    );

    // Persistencia local (solo access + identidad + role=admin; sin refresh)
    await _local.saveUserSession(
      accessToken: access,
      refreshToken: null,
      role: 'admin',
      name: admin.name,
      email: admin.email,
      avatarUrl: admin.avatarUrl,
    );

    return AdminSession(
      tokens: AuthTokens(accessToken: access),
      admin: admin,
    );
  }

  @override
  Future<User> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final data = await _remote.registerUser(
      email: email,
      name: name,
      password: password,
    );

    return User(
      id: data['id'] as int?,
      uuid: data['uuid'] as String?,
      email: data['email'] as String?,
      name: data['name'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      isActive: data['isActive'] as bool?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is String
              ? DateTime.tryParse(data['createdAt'] as String)
              : data['createdAt'] as DateTime?)
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is String
              ? DateTime.tryParse(data['updatedAt'] as String)
              : data['updatedAt'] as DateTime?)
          : null,
    );
  }

  @override
  Future<void> logoutUser() async {
    await _remote.logoutUser();
    await _local.clearAll();
  }

  @override
  Future<void> logoutAdmin() async {
    await _remote.logoutAdmin();
    await _local.clearAll();
  }

  /// Recupera lo que haya en secure storage y lo entrega tal cual.
  Future<({String? accessToken, String? refreshToken, String? role})>
      readStoredSession() async {
    final accessToken = await _local.readAccessToken();
    final refreshToken = await _local.readRefreshToken();
    final role = await _local.readAuthRole();
    return (
      accessToken: accessToken,
      refreshToken: refreshToken,
      role: role,
    );
  }
}