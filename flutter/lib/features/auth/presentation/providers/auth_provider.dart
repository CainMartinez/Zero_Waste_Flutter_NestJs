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

import 'package:pub_diferent/features/profile/presentation/providers/profile_provider.dart';

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

class AuthNotifier extends Notifier<AsyncValue<AuthViewState>> {
  late AuthUseCases _auth;
  bool _initialized = false;
  bool _manuallySet = false;
  
  @override
  AsyncValue<AuthViewState> build() {
    if (!_initialized) {
      _initialized = true;
      _initialize();
    }
    
    return const AsyncValue.loading();
  }

  Future<void> _initialize() async {
    final remote = AuthRemoteDataSource();
    final local = AuthLocalDataSource();
    final AuthRepository repo = AuthRepositoryImpl(remote, local);
    _auth = AuthUseCases(repo);

    final stored = await _auth.readStoredSession();
    final access = stored.accessToken;
    
    if (_manuallySet) {
      return;
    }
    
    if (access == null || access.isEmpty) {
      state = const AsyncValue.data(AuthViewState.anonymous());
      return;
    }

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

      state = AsyncValue.data(AuthViewState(
        adminSession: AdminSession(
          tokens: AuthTokens(accessToken: access),
          admin: admin,
        ),
      ));
      return;
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

    state = AsyncValue.data(AuthViewState(
      userSession: UserSession(
        tokens: AuthTokens(
          accessToken: access,
          refreshToken: stored.refreshToken,
        ),
        user: user,
      ),
    ));
  }

  Future<void> loginUser(String email, String password) async {
    try {
      _manuallySet = true;
      state = const AsyncValue.loading();
      final session = await _auth.loginUser(email: email, password: password);
      state = AsyncValue.data(AuthViewState(userSession: session));
      ref.invalidate(profileProvider);
    } catch (e, st) {
      _manuallySet = false;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loginAdmin(String email, String password) async {
    try {
      _manuallySet = true;
      state = const AsyncValue.loading();
      final session = await _auth.loginAdmin(email: email, password: password);
      state = AsyncValue.data(AuthViewState(adminSession: session));
      ref.invalidate(profileProvider);
    } catch (e, st) {
      _manuallySet = false;
      state = AsyncValue.error(e, st);
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
    final current = state.value;
    
    try {
      if (current != null && current.isAdmin) {
        await _auth.logoutAdmin();
      } else {
        await _auth.logoutUser();
      }
      
      state = const AsyncValue.data(AuthViewState.anonymous());
      ref.invalidate(profileProvider);
    } catch (e, st) {
      state = const AsyncValue.data(AuthViewState.anonymous());
      ref.invalidate(profileProvider);
      state = AsyncValue.error(e, st);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AsyncValue<AuthViewState>>(() {
  return AuthNotifier();
});