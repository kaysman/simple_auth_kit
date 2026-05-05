/// Access and refresh token pair returned by the auth endpoints.
class AuthTokens {
  /// Creates an [AuthTokens].
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiresAt,
    required this.refreshExpiresAt,
  });

  /// Short-lived JWT used to authenticate API requests.
  final String accessToken;

  /// Long-lived token used to obtain a new [accessToken].
  final String refreshToken;

  /// When the access token expires (UTC).
  final DateTime accessExpiresAt;

  /// When the refresh token expires (UTC).
  final DateTime refreshExpiresAt;

  /// Whether the access token is expired.
  bool get isAccessExpired => DateTime.now().isAfter(accessExpiresAt);

  /// Whether the refresh token is expired.
  bool get isRefreshExpired => DateTime.now().isAfter(refreshExpiresAt);
}
