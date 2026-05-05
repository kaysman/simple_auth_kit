# simple_auth_kit

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

> I kept rewriting the same JWT login / refresh / restore flow for every
> Flutter app I built, so I extracted it into a package. Open-sourcing it
> in case someone else finds it useful.

JWT login, refresh, logout, and session restore on top of an injectable HTTP
client. Tokens are persisted via `secure_token_storage`.

## Usage

The package depends on an [`AuthHttpClient`] to send requests. Use the
bundled `SimpleApiAuthHttpClient` (backed by `simple_api_client`) or
implement the interface yourself to plug in `dio`, `chopper`, or another
HTTP stack.

```dart
import 'package:secure_token_storage/secure_token_storage.dart';
import 'package:simple_api_client/simple_api_client.dart';
import 'package:simple_auth_kit/simple_auth_kit.dart';

final api = SimpleApiClient(baseUrl: 'https://api.example.com');

final auth = AuthRepository(
  httpClient: SimpleApiAuthHttpClient(api),
  tokenStorage: const SecureTokenStorage(),
);

final tokens = await auth.login(username: 'me', password: '...');
```

### Custom HTTP client

Implement `AuthHttpClient` and pass it to `AuthRepository` instead of
`SimpleApiAuthHttpClient`:

```dart
class MyDioAuthHttpClient implements AuthHttpClient {
  // ... wire post / setAccessToken / clearAccessToken to your stack
}
```

## Backend contract

The repository hits these endpoints, expects this JSON shape, and assumes
the response is wrapped in the `simple_api_client` envelope
(`{ data, message, success }`):

| Endpoint        | Request body                           | `data` payload                                                                                  |
| --------------- | -------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `/auth/login`   | `{ username, password }`               | `{ access_token, refresh_token, access_expiry_minutes, refresh_expiry_days }`                   |
| `/auth/refresh` | `{ refresh_token }`                    | same as above                                                                                   |
| `/auth/logout`  | `{ refresh_token }`                    | ignored                                                                                         |

If your backend differs, implement `AuthHttpClient` to translate or fork
this package.

## Tests

```sh
flutter test
```

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
