class AuthTokens {
  final String accessToken;

  const AuthTokens({required this.accessToken});

  AuthTokens copyWith({String? accessToken}) {
    return AuthTokens(accessToken: accessToken ?? this.accessToken);
  }

  bool get isEmpty => accessToken.isEmpty;
  bool get isNotEmpty => accessToken.isNotEmpty;

  @override
  String toString() => 'AuthTokens(accessToken: ****)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthTokens && other.accessToken == accessToken;
  }

  @override
  int get hashCode => accessToken.hashCode;
}