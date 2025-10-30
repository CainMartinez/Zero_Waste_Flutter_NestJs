import 'package:pub_diferent/features/auth/domain/entities/auth_tokens.dart';
import 'package:pub_diferent/features/auth/domain/entities/admin.dart';

class AdminSession {
  final AuthTokens tokens;
  final Admin admin;

  const AdminSession({
    required this.tokens,
    required this.admin,
  });

  AdminSession copyWith({
    AuthTokens? tokens,
    Admin? admin,
  }) {
    return AdminSession(
      tokens: tokens ?? this.tokens,
      admin: admin ?? this.admin,
    );
  }

  @override
  String toString() =>
      'AdminSession(admin: ${admin.email}, token: ${tokens.accessToken.substring(0, 10)}...)';
}