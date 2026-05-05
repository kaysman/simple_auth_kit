import 'package:simple_auth_kit/src/auth_tokens.dart';

/// Contract for authentication operations.
abstract interface class IAuthRepository {
  /// Authenticates with [username] and [password].
  ///
  /// Returns an [AuthTokens] pair on success.
  Future<AuthTokens> login({
    required String username,
    required String password,
  });

  /// Revokes [refreshToken] on the server and ends the session.
  Future<void> logout({required String refreshToken});

  /// Exchanges [refreshToken] for a new [AuthTokens] pair.
  Future<AuthTokens> refresh({required String refreshToken});

  /// Reads persisted tokens from secure storage.
  ///
  /// Returns `null` if no session exists.
  Future<AuthTokens?> restoreSession();
}
