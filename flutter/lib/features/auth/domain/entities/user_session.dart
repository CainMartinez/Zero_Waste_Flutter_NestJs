import 'package:pub_diferent/features/auth/domain/entities/auth_tokens.dart';
import 'package:pub_diferent/features/auth/domain/entities/user.dart';

class UserSession {
  final AuthTokens tokens;
  final User user;

  const UserSession({
    required this.tokens,
    required this.user,
  });

  UserSession copyWith({
    AuthTokens? tokens,
    User? user,
  }) {
    return UserSession(
      tokens: tokens ?? this.tokens,
      user: user ?? this.user,
    );
  }

  bool get hasRefresh => tokens.hasRefresh;

  @override
  String toString() {
    final preview = tokens.accessToken.isNotEmpty
        ? '${tokens.accessToken.substring(0, 10)}...'
        : 'empty';
    return 'UserSession(user: ${user.email}, access: $preview, refresh: ${tokens.hasRefresh ? "****" : "null"})';
  }
}