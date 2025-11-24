import 'package:eco_bocado/core/utils/app_services.dart';
import 'package:eco_bocado/core/utils/constants.dart';

const _sessionNameKey = 'auth_session_name';
const _sessionEmailKey = 'auth_session_email';
const _sessionAvatarKey = 'auth_session_avatar';

class AuthLocalDataSource {
  const AuthLocalDataSource();

  Future<void> saveUserSession({
    required String accessToken,
    String? refreshToken,
    required String role, // <- nuevo parámetro
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    await AppServices.storage.write(key: tokenKey, value: accessToken);
    await AppServices.storage.write(key: authRoleKey, value: role);

    if (refreshToken != null && refreshToken.isNotEmpty) {
      await AppServices.storage.write(key: refreshKey, value: refreshToken);
    } else {
      await AppServices.storage.delete(key: refreshKey);
    }

    final safeName = name?.toString();
    final safeEmail = email?.toString();
    final safeAvatar = avatarUrl?.toString();

    if (safeName != null && safeName.isNotEmpty) {
      await AppServices.storage.write(key: _sessionNameKey, value: safeName);
    } else {
      await AppServices.storage.delete(key: _sessionNameKey);
    }

    if (safeEmail != null && safeEmail.isNotEmpty) {
      await AppServices.storage.write(key: _sessionEmailKey, value: safeEmail);
    } else {
      await AppServices.storage.delete(key: _sessionEmailKey);
    }

    if (safeAvatar != null && safeAvatar.isNotEmpty) {
      await AppServices.storage.write(key: _sessionAvatarKey, value: safeAvatar);
    } else {
      await AppServices.storage.delete(key: _sessionAvatarKey);
    }

    // Delay para esperar a que el storage termine de escribir
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<String?> readAccessToken() =>
      AppServices.storage.read(key: tokenKey);

  Future<String?> readRefreshToken() =>
      AppServices.storage.read(key: refreshKey);

  Future<String?> readAuthRole() =>
      AppServices.storage.read(key: authRoleKey);

  Future<String?> readSessionName() =>
      AppServices.storage.read(key: _sessionNameKey);

  Future<String?> readSessionEmail() =>
      AppServices.storage.read(key: _sessionEmailKey);

  Future<String?> readSessionAvatar() =>
      AppServices.storage.read(key: _sessionAvatarKey);

  Future<void> clearAll() async {
    // Eliminar de una en una para evitar problemas de caché
    await AppServices.storage.delete(key: tokenKey);
    await AppServices.storage.delete(key: refreshKey);
    await AppServices.storage.delete(key: authRoleKey);
    await AppServices.storage.delete(key: _sessionNameKey);
    await AppServices.storage.delete(key: _sessionEmailKey);
    await AppServices.storage.delete(key: _sessionAvatarKey);
    
    // Forzar flush escribiendo y borrando una key dummy
    await AppServices.storage.write(key: '_flush', value: 'flush');
    await AppServices.storage.delete(key: '_flush');
    
    // Esperar a que se complete
    await Future.delayed(const Duration(milliseconds: 100));
  }
}