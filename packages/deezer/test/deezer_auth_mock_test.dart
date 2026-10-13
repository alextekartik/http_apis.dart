import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:test/test.dart';

/// Every http.Client() (and http.get) is a MockClient, no network.
void main() {
  late List<Uri> requests;
  late String tokenExchangeBody;

  http.Client mockClient() => MockClient((request) async {
    var uri = request.url;
    requests.add(uri);
    var path = uri.path;
    if (path.endsWith('access_token.php')) {
      return http.Response(tokenExchangeBody, 200);
    }
    if (path.endsWith('/artist/27')) {
      return http.Response(jsonEncode({'id': 27, 'name': 'Daft Punk'}), 200);
    }
    if (path.endsWith('/artist/500')) {
      return http.Response('server error', 500);
    }
    if (path.endsWith('/user/me')) {
      if (uri.queryParameters['access_token'] == null) {
        return http.Response(
          jsonEncode({
            'error': {
              'type': 'OAuthException',
              'message': 'An active access token must be used',
              'code': 200,
            },
          }),
          200,
        );
      }
      return http.Response(jsonEncode({'id': 5, 'name': 'Me'}), 200);
    }
    return http.Response(
      jsonEncode({
        'error': {'type': 'DataException', 'message': 'no data', 'code': 800},
      }),
      200,
    );
  });

  Future<T> withMock<T>(Future<T> Function() body) =>
      http.runWithClient(body, mockClient);

  DeezerApi newApi({String? code, String? accessToken}) => DeezerApi(
    code: code,
    accessToken: accessToken,
    options: DeezerApiOptions(appId: 'id', redirectUri: 'r', appSecret: 'x'),
    useJsonp: false,
  );

  setUp(() {
    requests = [];
    tokenExchangeBody = 'access_token=tok&expires=3600';
  });

  test('access token', () async {
    await withMock(() async {
      var api = newApi(accessToken: 'tok0');
      expect((await api.getMe()).name.v, 'Me');
      expect((await api.getArtist('27')).name.v, 'Daft Punk');
      expect(requests.map((uri) => uri.queryParameters['access_token']), [
        'tok0',
        'tok0',
      ]);
    });
  });

  test('code only, getMe exchanges the code first', () async {
    await withMock(() async {
      // Used to fail on a null check before any request.
      var api = newApi(code: 'code');
      expect((await api.getMe()).name.v, 'Me');
      expect((await api.getUser('me')).id.v, '5');
      // Exchanged once.
      expect(
        requests.where((uri) => uri.path.endsWith('access_token.php')),
        hasLength(1),
      );
      expect(requests.last.queryParameters['access_token'], 'tok');
    });
  });

  test('failed code exchange', () async {
    tokenExchangeBody = 'wrong code';
    await withMock(() async {
      var api = newApi(code: 'code');
      // Used to be a null check TypeError.
      for (var action in [() => api.getMe(), () => api.getArtist('27')]) {
        try {
          await action();
          fail('should fail');
        } on DeezerApiException catch (e) {
          expect(e.httpStatusCode, 200);
          expect(e.rawBody, 'wrong code');
        }
      }
      expect(await api.getAccessToken(), isNull);
      expect(
        requests.every((uri) => uri.path.endsWith('access_token.php')),
        isTrue,
      );
    });
  });

  test('getMe without token nor code', () async {
    await withMock(() async {
      var api = newApi();
      // Used to fail on a null check, now the Deezer error.
      try {
        await api.getMe();
        fail('should fail');
      } on DeezerApiException catch (e) {
        expect(e.errorInfo!.type.v, 'OAuthException');
      }
      expect(requests.single.queryParameters['access_token'], isNull);
    });
  });

  test('deezer error', () async {
    await withMock(() async {
      var api = newApi();
      await expectLater(api.getArtist('0'), throwsA(isA<DeezerApiException>()));
    });
  });

  test('http error with debugDeezerApi', () async {
    var prints = <String>[];
    await runZoned(
      () => withMock(() async {
        debugDeezerApi = true;
        try {
          var api = newApi();
          try {
            await api.getArtist('500');
            fail('should fail');
          } on DeezerApiException catch (e) {
            expect(e.httpStatusCode, 500);
            expect(e.rawBody, 'server error');
          }
        } finally {
          debugDeezerApi = false;
        }
      }),
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) => prints.add(line),
      ),
    );
    // The error body used to be read twice in debug mode.
    expect(
      prints.where((line) => line.contains('already been listened')),
      isEmpty,
    );
    expect(prints.where((line) => line.contains('server error')), hasLength(1));
  });
}
