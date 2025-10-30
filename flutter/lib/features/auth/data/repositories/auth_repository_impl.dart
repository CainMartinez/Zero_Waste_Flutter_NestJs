import 'package:pub_diferent/features/auth/domain/repositories/auth_repository.dart';
import 'package:pub_diferent/features/auth/domain/entities/auth_tokens.dart';
import 'package:pub_diferent/features/auth/domain/entities/user.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin.dart';
import 'package:pub_diferent/features/auth/domain/entities/user_session.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin_session.dart';
import 'package:pub_diferent/features/auth/data/dto/request/login_request_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/request/admin_login_request_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/request/register_user_request_dto.dart';
import 'package:pub_diferent/features/auth/data/datasources/login_user_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/login_admin_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/register_user_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/logout_user_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/datasources/logout_admin_remote_datasource.dart';
import 'package:pub_diferent/features/auth/data/dto/response/user_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/admin_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/auth_user_login_response_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/auth_admin_login_response_dto.dart';
import 'package:pub_diferent/features/auth/data/dto/response/register_user_response_dto.dart';

/// Implementación de AuthRepository en la capa de datos.
/// - Orquesta datasources.
/// - Convierte DTOs ⇢ Entidades de dominio.
class AuthRepositoryImpl implements AuthRepository {
  final LoginUserRemoteDataSource _loginUserDS;
  final AdminLoginRemoteDataSource _loginAdminDS;
  final RegisterUserRemoteDataSource _registerUserDS;
  final LogoutUserRemoteDataSource _logoutUserDS;
  final LogoutAdminRemoteDataSource _logoutAdminDS;

  const AuthRepositoryImpl({
    required LoginUserRemoteDataSource loginUserDataSource,
    required AdminLoginRemoteDataSource loginAdminDataSource,
    required RegisterUserRemoteDataSource registerUserDataSource,
    required LogoutUserRemoteDataSource logoutUserDataSource,
    required LogoutAdminRemoteDataSource logoutAdminDataSource,
  })  : _loginUserDS = loginUserDataSource,
        _loginAdminDS = loginAdminDataSource,
        _registerUserDS = registerUserDataSource,
        _logoutUserDS = logoutUserDataSource,
        _logoutAdminDS = logoutAdminDataSource;

  @override
  Future<UserSession> loginUser({
    required String email,
    required String password,
  }) async {
    final req = LoginRequestDto.create(email: email, password: password);

    final errors = req.validate();
    if (errors != null) {
      throw ArgumentError('Login inválido: ${errors.values.join(', ')}');
    }

    final AuthUserLoginResponseDto dto = await _loginUserDS.call(req);

    final tokens = AuthTokens(accessToken: dto.accessToken);
    final user = _mapUserDtoToDomain(dto.user);

    return UserSession(tokens: tokens, user: user);
  }

  @override
  Future<AdminSession> loginAdmin({
    required String email,
    required String password,
  }) async {
    final req = AdminLoginRequestDto.create(email: email, password: password);
    final errors = req.validate();
    if (errors != null) {
      throw ArgumentError('Login admin inválido: ${errors.values.join(', ')}');
    }

    final AuthAdminLoginResponseDto dto = await _loginAdminDS.call(req);

    final tokens = AuthTokens(accessToken: dto.accessToken);
    final admin = _mapAdminDtoToDomain(dto.admin);

    return AdminSession(tokens: tokens, admin: admin);
  }

  @override
  Future<User> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final req = RegisterUserRequestDto.create(
      email: email,
      name: name,
      password: password,
    );

    final errors = req.validate();
    if (errors != null) {
      throw ArgumentError('Registro inválido: ${errors.values.join(', ')}');
    }

    final RegisterUserResponseDto dto = await _registerUserDS.call(req);
    return _mapUserDtoToDomain(dto.user);
  }

  @override
  Future<void> logoutUser({required String accessToken}) {
    return _logoutUserDS.call(accessToken: accessToken);
  }

  @override
  Future<void> logoutAdmin({required String accessToken}) {
    return _logoutAdminDS.call(accessToken: accessToken);
  }

  User _mapUserDtoToDomain(UserDto d) {
    return User(
      id: d.id,
      uuid: d.uuid,
      email: d.email,
      name: d.name,
      avatarUrl: d.avatarUrl,
      isActive: d.isActive ?? true,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }

  Admin _mapAdminDtoToDomain(AdminDto d) {
    return Admin(
      id: d.id,
      uuid: d.uuid,
      email: d.email,
      name: d.name,
      avatarUrl: d.avatarUrl,
      isActive: d.isActive ?? true,
      createdAt: d.createdAt,
      updatedAt: d.updatedAt,
    );
  }
}