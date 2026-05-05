/// Minimal HTTP surface that [AuthRepository] needs from a transport client.
///
/// Implement this to plug `dio`, `chopper`, or any other HTTP stack into
/// `simple_auth_kit`. Use [SimpleApiAuthHttpClient] (the bundled default) if
/// you have no preference.
abstract interface class AuthHttpClient {
  /// Issues a POST to [path] with [body] and returns the deserialized
  /// response payload (with any envelope already unwrapped).
  Future<T> post<T>(
    String path, {
    required Object body,
    required T Function(Object? json) fromData,
  });

  /// Sets the bearer access token used for subsequent authenticated requests.
  void setAccessToken(String token);

  /// Clears the bearer access token.
  void clearAccessToken();
}
