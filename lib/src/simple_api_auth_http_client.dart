import 'package:simple_api_client/simple_api_client.dart';
import 'package:simple_auth_kit/src/auth_http_client.dart';

/// Default [AuthHttpClient] implementation backed by a [SimpleApiClient].
class SimpleApiAuthHttpClient implements AuthHttpClient {
  /// Creates a [SimpleApiAuthHttpClient] that delegates to [client].
  const SimpleApiAuthHttpClient(this._client);

  final SimpleApiClient _client;

  @override
  Future<T> post<T>(
    String path, {
    required Object body,
    required T Function(Object? json) fromData,
  }) =>
      _client.post<T>(path, body: body, fromData: fromData);

  @override
  void setAccessToken(String token) => _client.setAccessToken(token);

  @override
  void clearAccessToken() => _client.clearAccessToken();
}
