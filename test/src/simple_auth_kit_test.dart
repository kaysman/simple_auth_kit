// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:secure_token_storage/secure_token_storage.dart';
import 'package:simple_api_client/simple_api_client.dart';
import 'package:simple_auth_kit/simple_auth_kit.dart';

class _MockHttpClient extends Mock implements http.Client {}

class _MockSecureTokenStorage extends Mock implements SecureTokenStorage {}

class _FakeTokenBundle extends Fake implements TokenBundle {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTokenBundle());
  });

  late _MockHttpClient httpClient;
  late SimpleApiClient apiClient;
  late AuthRepository repository;
  late _MockSecureTokenStorage tokenStorage;

  setUp(() {
    httpClient = _MockHttpClient();
    apiClient = SimpleApiClient(
      baseUrl: 'http://test.local',
      httpClient: httpClient,
    );
    tokenStorage = _MockSecureTokenStorage();
    when(() => tokenStorage.save(any())).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
    repository = AuthRepository(
      httpClient: SimpleApiAuthHttpClient(apiClient),
      tokenStorage: tokenStorage,
    );
  });

  group('AuthRepository', () {
    group('login', () {
      test('returns AuthTokens on 200', () async {
        when(
          () => httpClient.post(
            Uri.parse('http://test.local/auth/login'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'access_token': 'access.jwt',
                'refresh_token': 'refresh.jwt',
                'access_expiry_minutes': 15,
                'refresh_expiry_days': 30,
              },
            }),
            200,
          ),
        );

        final tokens = await repository.login(
          username: 'mekanata',
          password: '12345678',
        );

        expect(tokens.accessToken, 'access.jwt');
        expect(tokens.refreshToken, 'refresh.jwt');
      });

      test('throws ApiException on 401', () async {
        when(
          () => httpClient.post(
            Uri.parse('http://test.local/auth/login'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'success': false,
              'data': 'invalid credentials',
              'message': 'Unauthorized',
            }),
            401,
          ),
        );

        expect(
          () => repository.login(username: 'bad', password: 'wrong'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 401)
                .having((e) => e.message, 'message', 'Unauthorized'),
          ),
        );
      });
    });

    group('logout', () {
      test('completes on 200', () async {
        when(
          () => httpClient.post(
            Uri.parse('http://test.local/auth/logout'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': 'logged out',
              'message': 'ok',
            }),
            200,
          ),
        );

        await expectLater(
          repository.logout(refreshToken: 'refresh.jwt'),
          completes,
        );
      });
    });

    group('refresh', () {
      test('returns new AuthTokens on 200', () async {
        when(
          () => httpClient.post(
            Uri.parse('http://test.local/auth/refresh'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'access_token': 'new.access.jwt',
                'refresh_token': 'new.refresh.jwt',
                'access_expiry_minutes': 15,
                'refresh_expiry_days': 30,
              },
            }),
            200,
          ),
        );

        final tokens = await repository.refresh(refreshToken: 'refresh.jwt');

        expect(tokens.accessToken, 'new.access.jwt');
        expect(tokens.refreshToken, 'new.refresh.jwt');
      });

      test('throws ApiException on 401', () async {
        when(
          () => httpClient.post(
            Uri.parse('http://test.local/auth/refresh'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'success': false,
              'data': 'token expired',
              'message': 'Unauthorized',
            }),
            401,
          ),
        );

        expect(
          () => repository.refresh(refreshToken: 'expired.jwt'),
          throwsA(isA<ApiException>()),
        );
      });
    });
  });
}
