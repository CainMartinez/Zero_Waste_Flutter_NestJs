import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/auth_tokens.dart';
import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin.dart';
import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';

import 'package:http/http.dart' as http;
import 'package:pub_diferent/features/auth/data/datasources/login_user_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/login_admin_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/register_user_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/logout_user_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/logout_admin_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/repositories/auth_repository_impl.dart';

/// Clave de almacenamiento en SharedPreferences
const _authKey = 'auth_session_v1';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = http.Client();
  return AuthRepositoryImpl(
    loginUserDataSource: LoginUserRemoteDataSource(client: client),
    loginAdminDataSource: AdminLoginRemoteDataSource(client: client),
    registerUserDataSource: RegisterUserRemoteDataSource(client: client),
    logoutUserDataSource: LogoutUserRemoteDataSource(client: client),
    logoutAdminDataSource: LogoutAdminRemoteDataSource(client: client),
  );
});

class AuthState {
  final UserSession? userSession;
  final AdminSession? adminSession;
  final bool isLoading;
  final bool hydrated;

  const AuthState({
    this.userSession,
    this.adminSession,
    this.isLoading = false,
    this.hydrated = false,
  });

  bool get isAuthenticated => userSession != null || adminSession != null;
  bool get isAdmin => adminSession != null;

  AuthState copyWith({
    UserSession? userSession,
    AdminSession? adminSession,
    bool? isLoading,
    bool? hydrated,
  }) {
    return AuthState(
      userSession: userSession ?? this.userSession,
      adminSession: adminSession ?? this.adminSession,
      isLoading: isLoading ?? this.isLoading,
      hydrated: hydrated ?? this.hydrated,
    );
  }

  factory AuthState.initial() => const AuthState();

}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(AuthState.initial()) {
    _loadFromPrefs();
  }

  final AuthRepository _repo;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_authKey);

    if (jsonString == null) {
      state = state.copyWith(hydrated: true);
      return;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final type = data['type'];

      if (type == 'user') {
        final user = User(
          id: data['id'],
          uuid: data['uuid'],
          email: data['email'],
          name: data['name'],
          avatarUrl: data['avatarUrl'],
        );
        final session = UserSession(
          tokens: AuthTokens(accessToken: data['accessToken']),
          user: user,
        );
        state = AuthState(userSession: session, hydrated: true);
      } else if (type == 'admin') {
        final admin = Admin(
          id: data['id'],
          uuid: data['uuid'],
          email: data['email'],
          name: data['name'],
          avatarUrl: data['avatarUrl'],
        );
        final session = AdminSession(
          tokens: AuthTokens(accessToken: data['accessToken']),
          admin: admin,
        );
        state = AuthState(adminSession: session, hydrated: true);
      }
    } catch (_) {
      await prefs.remove(_authKey);
      state = state.copyWith(hydrated: true);
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    if (state.userSession != null) {
      final s = state.userSession!;
      await prefs.setString(
        _authKey,
        jsonEncode({
          'type': 'user',
          'accessToken': s.tokens.accessToken,
          'id': s.user.id,
          'uuid': s.user.uuid,
          'email': s.user.email,
          'name': s.user.name,
          'avatarUrl': s.user.avatarUrl,
        }),
      );
    } else if (state.adminSession != null) {
      final s = state.adminSession!;
      await prefs.setString(
        _authKey,
        jsonEncode({
          'type': 'admin',
          'accessToken': s.tokens.accessToken,
          'id': s.admin.id,
          'uuid': s.admin.uuid,
          'email': s.admin.email,
          'name': s.admin.name,
          'avatarUrl': s.admin.avatarUrl,
        }),
      );
    } else {
      await prefs.remove(_authKey);
    }
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authKey);
  }

  Future<void> loginUser(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await _repo.loginUser(email: email, password: password);
      state = AuthState(userSession: session, hydrated: true);
      await _saveToPrefs();
    } catch (_) {
      state = AuthState(hydrated: true);
    }
  }

  Future<void> loginAdmin(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final session = await _repo.loginAdmin(email: email, password: password);
      state = AuthState(adminSession: session, hydrated: true);
      await _saveToPrefs();
    } catch (_) {
      state = AuthState(hydrated: true);
    }
  }

  Future<void> logout() async {
    await _clearPrefs();
    state = AuthState(hydrated: true);
  }
}

final authProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});