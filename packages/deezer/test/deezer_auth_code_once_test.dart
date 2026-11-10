import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:test/test.dart';

/// Deezer accepts an OAuth code once: a second exchange answers
/// 'wrong code'. Every http.Client() is this mock, no network.
void main() {
  late List<Uri> requests;
  late Set<String> usedCodes;

  http.Client mockClient() => MockClient((request) async {
    var uri = request.url;
    requests.add(uri);
    if (uri.path.endsWith('access_token.php')) {
      var code = uri.queryParameters['code']!;
      if (!usedCodes.add(code)) {
        return http.Response('wrong code', 200);
      }
      return http.Response('access_token=tok&expires=3600', 200);
    }
    if (uri.path.endsWith('/user/me') &&
        uri.queryParameters['access_token'] == 'tok') {
      return http.Response('{"id": 5, "name": "Me"}', 200);
    }
    return http.Response(
      '{"error": {"type": "OAuthException", "message": "no", "code": 200}}',
      200,
    );
  });

  DeezerApi newApi() => DeezerApi(
    code: 'code',
    options: DeezerApiOptions(appId: 'id', redirectUri: 'r', appSecret: 'x'),
    useJsonp: false,
  );

  Iterable<Uri> exchanges() =>
      requests.where((uri) => uri.path.endsWith('access_token.php'));

  setUp(() {
    requests = [];
    usedCodes = {};
  });

  test('getAccessToken then getMe exchange the code once', () async {
    await http.runWithClient(() async {
      var api = newApi();
      expect(await api.getAccessToken(), 'tok');
      // Used to exchange the code again: DeezerApiException 'wrong code'.
      expect((await api.getMe()).name.v, 'Me');
      expect(exchanges(), hasLength(1));
    }, mockClient);
  });

  test('getMe then getAccessToken exchange the code once', () async {
    await http.runWithClient(() async {
      var api = newApi();
      expect((await api.getMe()).name.v, 'Me');
      // Used to exchange the code again and return null.
      expect(await api.getAccessToken(), 'tok');
      expect(exchanges(), hasLength(1));
    }, mockClient);
  });
}
