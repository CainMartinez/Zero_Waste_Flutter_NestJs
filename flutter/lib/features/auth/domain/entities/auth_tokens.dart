class AuthTokens {
  final String accessToken;
  final String? refreshToken;

  const AuthTokens({
    required this.accessToken,
    this.refreshToken,
  });

  AuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  bool get hasRefresh => refreshToken != null && refreshToken!.isNotEmpty;
  bool get isEmpty => accessToken.isEmpty;
  bool get isNotEmpty => accessToken.isNotEmpty;

  @override
  String toString() =>
      'AuthTokens(accessToken: ****, refreshToken: ${hasRefresh ? "****" : "null"})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthTokens &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => accessToken.hashCode ^ (refreshToken?.hashCode ?? 0);
}