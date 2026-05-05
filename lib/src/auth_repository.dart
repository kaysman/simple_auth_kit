import 'package:secure_token_storage/secure_token_storage.dart';
import 'package:simple_auth_kit/src/auth_http_client.dart';
import 'package:simple_auth_kit/src/auth_tokens.dart';
import 'package:simple_auth_kit/src/i_auth_repository.dart';

/// Drives the JWT login / refresh / logout / restore lifecycle and persists
/// tokens via [SecureTokenStorage].
class AuthRepository implements IAuthRepository {
  /// Creates an [AuthRepository].
  AuthRepository({
    required AuthHttpClient httpClient,
    required SecureTokenStorage tokenStorage,
  }) : _httpClient = httpClient,
       _tokenStorage = tokenStorage;

  final AuthHttpClient _httpClient;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<AuthTokens> login({
    required String username,
    required String password,
  }) async {
    final tokens = await _httpClient.post<AuthTokens>(
      '/auth/login',
      body: {'username': username, 'password': password},
      fromData: _tokensFromData,
    );
    await _save(tokens);
    return tokens;
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _httpClient.post<bool>(
        '/auth/logout',
        body: {'refresh_token': refreshToken},
        fromData: (_) => true,
      );
    } finally {
      _httpClient.clearAccessToken();
      await _tokenStorage.clear();
    }
  }

  @override
  Future<AuthTokens> refresh({required String refreshToken}) async {
    final tokens = await _httpClient.post<AuthTokens>(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
      fromData: _tokensFromData,
    );
    await _save(tokens);
    return tokens;
  }

  @override
  Future<AuthTokens?> restoreSession() async {
    final stored = await _tokenStorage.read();
    if (stored == null) return null;

    final tokens = AuthTokens(
      accessToken: stored.accessToken,
      refreshToken: stored.refreshToken,
      accessExpiresAt: stored.accessExpiresAt,
      refreshExpiresAt: stored.refreshExpiresAt,
    );

    if (tokens.isRefreshExpired) {
      await _tokenStorage.clear();
      return null;
    }

    if (tokens.isAccessExpired) {
      try {
        return await refresh(refreshToken: tokens.refreshToken);
      } on Exception {
        await _tokenStorage.clear();
        return null;
      }
    }

    _httpClient.setAccessToken(tokens.accessToken);
    return tokens;
  }

  Future<void> _save(AuthTokens tokens) {
    _httpClient.setAccessToken(tokens.accessToken);
    return _tokenStorage.save(
      TokenBundle(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        accessExpiresAt: tokens.accessExpiresAt,
        refreshExpiresAt: tokens.refreshExpiresAt,
      ),
    );
  }

  static AuthTokens _tokensFromData(Object? json) {
    final map = json! as Map<String, dynamic>;
    final now = DateTime.now();
    return AuthTokens(
      accessToken: map['access_token'] as String,
      refreshToken: map['refresh_token'] as String,
      accessExpiresAt: now.add(
        Duration(minutes: map['access_expiry_minutes'] as int),
      ),
      refreshExpiresAt: now.add(
        Duration(days: map['refresh_expiry_days'] as int),
      ),
    );
  }
}
