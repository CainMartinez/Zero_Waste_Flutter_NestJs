import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pub_diferent/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pub_diferent/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';
import 'package:pub_diferent/features/auth/domain/usecases/auth_usecase.dart';

import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin.dart';
import 'package:pub_diferent/features/auth/domain/entities/auth_tokens.dart';

class AuthViewState {
  final UserSession? userSession;
  final AdminSession? adminSession;

  const AuthViewState({
    this.userSession,
    this.adminSession,
  });

  const AuthViewState.anonymous()
      : userSession = null,
        adminSession = null;

  bool get isAuthenticated => userSession != null || adminSession != null;
  bool get isAnonymous => !isAuthenticated;
  bool get isAdmin => adminSession != null;

  String? get displayName =>
      userSession?.user.name ?? adminSession?.admin.name;

  String? get avatarUrl =>
      userSession?.user.avatarUrl ?? adminSession?.admin.avatarUrl;
}

class AuthNotifier extends AsyncNotifier<AuthViewState> {
  late final AuthUseCases _auth;

  @override
  Future<AuthViewState> build() async {
    // Orquestación de dependencias
    final remote = AuthRemoteDataSource();
    final local = AuthLocalDataSource();
    final AuthRepository repo = AuthRepositoryImpl(remote, local);
    _auth = AuthUseCases(repo);

    final stored = await _auth.readStoredSession();
    final access = stored.accessToken;
    if (access == null || access.isEmpty) {
      return const AuthViewState.anonymous();
    }

    // Relleno extendido desde storage local (según role)
    final name = await local.readSessionName();
    final email = await local.readSessionEmail();
    final avatar = await local.readSessionAvatar();

    final role = stored.role; // 'admin' | 'user'

    if (role == 'admin') {
      final admin = Admin(
        id: null,
        uuid: null,
        email: email ?? '',
        name: name ?? '',
        avatarUrl: avatar,
        isActive: true,
        createdAt: null,
        updatedAt: null,
      );

      return AuthViewState(
        adminSession: AdminSession(
          tokens: AuthTokens(accessToken: access),
          admin: admin,
        ),
      );
    }

    // Usuario normal
    final user = User(
      id: null,
      uuid: null,
      email: email ?? '',
      name: name ?? '',
      avatarUrl: avatar,
      isActive: true,
      createdAt: null,
      updatedAt: null,
    );

    return AuthViewState(
      userSession: UserSession(
        tokens: AuthTokens(
          accessToken: access,
          refreshToken: stored.refreshToken,
        ),
        user: user,
      ),
    );
  }

  Future<void> loginUser(String email, String password) async {
    try {
      state = const AsyncLoading();
      final session = await _auth.loginUser(email: email, password: password);
      state = AsyncValue.data(AuthViewState(userSession: session));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loginAdmin(String email, String password) async {
    try {
      state = const AsyncLoading();
      final session = await _auth.loginAdmin(email: email, password: password);
      state = AsyncValue.data(AuthViewState(adminSession: session));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<User?> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      state = const AsyncLoading();
      final user = await _auth.registerUser(
        email: email,
        name: name,
        password: password,
      );
      state = const AsyncValue.data(AuthViewState.anonymous());
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> logout() async {
    final current = state.hasValue ? state.value : null;
    state = const AsyncLoading();

    try {
      if (current != null && current.isAdmin) {
        await _auth.logoutAdmin();
      } else {
        await _auth.logoutUser();
      }
      state = const AsyncValue.data(AuthViewState.anonymous());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthViewState>(() {
  return AuthNotifier();
});