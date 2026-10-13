/// Not public
library;

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

class DeezerAuthClient extends http.BaseClient {
  final DeezerApi api;
  final _client = http.Client();
  String? authToken;
  DeezerAuthClient(this.api) {
    // assert(api.code != null || api.accessToken != null);
    // Use access token if available
    authToken = api.accessToken;
  }
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    late String body;
    late Uint8List bytes;
    late http.StreamedResponse response;

    /// Set body, bytes and response
    Future<void> doSend() async {
      var originalRequestUrl = request.url;
      var token = await _authTokenOrNull();
      var newRequest = token == null
          ? request.copyRequest()
          : request.copyRequest(
              url: _withAccessToken(originalRequestUrl, token),
            );
      if (debugDeezerApi) {
        print('[DQury] $originalRequestUrl');
      }

      response = await _client.send(newRequest);

      if (!isHttpStatusCodeSuccessful(response.statusCode)) {
        String? rawBody;
        try {
          bytes = await response.stream.toBytes();

          body = utf8.decode(bytes);
          rawBody = body;
          if (debugDeezerApi) {
            print('[DResp ${response.statusCode}] $body');
          }
        } catch (e) {
          print('[DResp ${response.statusCode}] error: $e');
        }
        throw DeezerApiException(
          httpStatusCode: response.statusCode,
          rawBody: rawBody,
        );
      }
      bytes = await response.stream.toBytes();

      body = utf8.decode(bytes);
      if (debugDeezerApi) {
        print('[DResp ${response.statusCode}] $body');
      }
      var error = body.cv<DeezerError>();
      if (error.error.v != null) {
        throw DeezerApiException(errorInfo: error.error.v!, rawBody: body);
      }
    }

    try {
      await doSend();
    } catch (e, st) {
      if (isDebug) {
        print('error $e');
        print(st);
      }

      rethrow;
    }
    return response.copyWithBytes(bytes);
  }

  /// The token to add to requests, null when there is neither a token nor a
  /// code to exchange.
  ///
  /// Throws a [DeezerApiException] if the code exchange fails.
  Future<String?> _authTokenOrNull() async {
    if (authToken == null && api.code == null) {
      return null;
    }
    if (authToken == null) {
      var exchange = await _exchangeCode();
      authToken =
          exchange.accessToken ??
          (throw DeezerApiException(
            httpStatusCode: exchange.statusCode,
            rawBody: exchange.body,
          ));
    }
    return authToken;
  }

  Uri _withAccessToken(Uri uri, String token) => uri.replace(
    queryParameters: Map<String, String>.from(uri.queryParameters)
      ..['access_token'] = token,
  );

  /// Exchange the code for an access token (null on failure).
  Future<({String? accessToken, int statusCode, String body})>
  _exchangeCode() async {
    var uri = Uri.parse('https://connect.deezer.com/oauth/access_token.php')
        .replace(
          queryParameters: {
            'app_id': api.options?.appId,
            'secret': api.options?.appSecret,
            'code': api.code,
          },
        );
    if (debugDeezerApi) {
      print('[DQury access_token] $uri');
    }
    var response = await http.get(uri);
    // access_token=xxx&expires=3600
    var body = response.body.trim();
    if (debugDeezerApi) {
      print('[DResp access token ${response.statusCode}] $body');
    }
    String? accessToken;
    if (body.startsWith('access_token')) {
      accessToken = body.split('=')[1].split('&')[0];
    }
    return (
      accessToken: accessToken,
      statusCode: response.statusCode,
      body: body,
    );
  }

  Future<String?> getAccessToken() async {
    if (api.code == null) {
      return api.accessToken;
    }
    return (await _exchangeCode()).accessToken;
  }

  Future<String> readString(Uri uri) async {
    var token = await _authTokenOrNull();
    if (token != null) {
      uri = _withAccessToken(uri, token);
    }
    return api.readString(uri);
  }
}
