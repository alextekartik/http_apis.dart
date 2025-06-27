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
    Future doSend() async {
      var originalRequestUrl = request.url;
      var url = originalRequestUrl;
      http.BaseRequest newRequest;
      if (authToken == null && api.code == null) {
        newRequest = request.copyRequest();
      } else {
        authToken ??= await getAccessToken();
        url = url.replace(
          queryParameters: Map<String, String>.from(url.queryParameters)
            ..['access_token'] = authToken!,
        );
        newRequest = request.copyRequest(url: url);
      }
      if (debugDeezerApi) {
        print('[DQury] $originalRequestUrl');
      }

      // var body = await api.readAny(url);
      //print('[DResp] ${body.runtimeType} $body');
      /*
      if (debugWebServices) {
        logD('${newRequest.method} ${newRequest.url} ${newRequest.headers}');
      }
      newRequest.headers['client_id'] = webServices.options2.clientId;
      newRequest.headers['client_secret'] = webServices.options2.clientSecret;
      newRequest.headers['Connection'] = 'keep-alive';
      newRequest.headers['Accept'] = httpContentTypeJson;
      */
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
        if (debugDeezerApi) {
          try {
            bytes = await response.stream.toBytes();

            body = utf8.decode(bytes);
            if (debugDeezerApi) {
              print('[DResp ${response.statusCode}] $body');
            }
          } catch (e) {
            print('[DResp ${response.statusCode}] error: $e');
          }
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

  Future<String?> getAccessToken() async {
    if (api.code == null) {
      return api.accessToken;
    }
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
    late String body;
    if (true) {
      var response = await http.get(uri);
      // access_token=frZ0joLUqBHyl9rMTReymQrh95cOxZiz30jAI7DaoOs6vANJgsw&expires=3600
      //print(response.body);
      //print(response.headers);
      body = response.body.trim();
      if (debugDeezerApi) {
        print('[DResp access token ${response.statusCode}] $body');
      }
      // ignore: dead_code
    } else {
      body = await api.readString(uri);
      if (debugDeezerApi) {
        print('[DResp access token $body');
      }
    }
    // print(body);
    if (body.startsWith('access_token')) {
      var accessToken = body.split('=')[1].split('&')[0];
      // print('accessToken: $accessToken');
      return accessToken;
    }
    return null;
  }

  Future<String> readString(Uri uri) {
    uri = uri.replace(
      queryParameters: Map<String, String>.from(uri.queryParameters)
        ..['access_token'] = authToken!,
    );
    return api.readString(uri);
  }
}
