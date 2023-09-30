import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

var debugDeezerApi = false;

class DeezerApiException implements Exception {
  final int? httpStatusCode;
  final DeezerErrorInfo? errorInfo;
  final String? rawBody;

  DeezerApiException(
      {this.errorInfo, this.httpStatusCode, required this.rawBody});

  @override
  String toString() => errorInfo != null
      ? '${errorInfo!.type.v}: ${errorInfo!.message.v}'
      : 'statusCode: $httpStatusCode';
}

class _AuthClient extends http.BaseClient {
  final DeezerApi api;
  final _client = http.Client();
  String? _authToken;
  _AuthClient(this.api);
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
      if (_authToken == null && api.code == null) {
        newRequest = request.copyRequest();
      } else {
        _authToken ??= await _getAccessToken();
        url = url.replace(
            queryParameters: Map<String, String>.from(url.queryParameters)
              ..['access_token'] = _authToken!);
        newRequest = request.copyRequest(url: url);
      }
      if (debugDeezerApi) {
        print('[DQury] $originalRequestUrl');
      }
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
            httpStatusCode: response.statusCode, rawBody: rawBody);
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

  Future<String?> _getAccessToken() async {
    if (api.code == null) {
      return api.accessToken;
    }
    var uri = Uri.parse('https://connect.deezer.com/oauth/access_token.php')
        .replace(queryParameters: {
      'app_id': api.options?.appId,
      'secret': api.options?.appSecret,
      'code': api.code
    });
    if (debugDeezerApi) {
      print('[DQury access_token] $uri');
    }
    var response = await http.get(uri);
    // access_token=frZ0joLUqBHyl9rMTReymQrh95cOxZiz30jAI7DaoOs6vANJgsw&expires=3600
    //print(response.body);
    //print(response.headers);
    var body = response.body.trim();
    if (debugDeezerApi) {
      print('[DResp access token ${response.statusCode}] $body');
    }
    // print(body);
    if (body.startsWith('access_token')) {
      var accessToken = body.split('=')[1].split('&')[0];
      // print('accessToken: $accessToken');
      return accessToken;
    }
    return null;
  }
}

class DeezerApiOptions {
  final String appId;
  final String redirectUri;
  final String appSecret;

  DeezerApiOptions(
      {required this.appId,
      required this.redirectUri,
      required this.appSecret});
}

class DeezerApi {
  final String? code;
  final String? accessToken;
  final DeezerApiOptions? options;

  late final _authClient = _AuthClient(this);

  @visibleForTesting
  set authToken(String authToken) {
    _authClient._authToken = authToken;
  }

  DeezerApi({this.code, this.accessToken, this.options}) {
    // assert(code != null || accessToken != null);
    initDeezerCvBuilders();
  }

  final _baseUrl = Uri.parse('http://api.deezer.com/2.0');
  Future<DeezerUser> getMe() async {
    var uri = Uri.parse('https://api.deezer.com/user/me');
    var body = await _authClient.read(uri);
    // print(body);
    return body.cv<DeezerUser>();
  }

  Uri _withAppendedPath(String path) {
    var uri = _baseUrl.replace(path: url.join(_baseUrl.path, path));
    return uri;
  }

  Future<DeezerArtist> getArtist(String id) async {
    return (await getArtistRaw(id)).cv<DeezerArtist>();
  }

  Future<Model> _readMap(Uri uri) async {
    var body = await _authClient.read(uri);
    return jsonDecode(body) as Model;
  }

  Future<Model> getArtistRaw(String id) async {
    var uri = _withAppendedPath('artist/$id');
    return await _readMap(uri);
  }

  Future<DeezerPlaylist> getPlaylist(String id) async {
    return (await getPlaylistRaw(id)).cv<DeezerPlaylist>();
  }

  Future<Model> getPlaylistRaw(String id) async {
    var uri = _withAppendedPath('playlist/$id');
    return await _readMap(uri);
  }

  // Get album picture too
  Future<DeezerPlaylist> getPlaylistTracks(String id) async {
    return (await getPlaylistTracksRaw(id)).cv<DeezerPlaylist>();
  }

  Future<Model> getPlaylistTracksRaw(String id) async {
    var uri = _withAppendedPath('playlist/$id/tracks');
    return await _readMap(uri);
  }

  Future<DeezerAlbum> getAlbum(String id) async {
    return (await getAlbumRaw(id)).cv<DeezerAlbum>();
  }

  Future<Model> getAlbumRaw(String id) async {
    var uri = _withAppendedPath('album/$id');
    return await _readMap(uri);
  }

  Future<String?> getAccessToken() async {
    return await _authClient._getAccessToken();
  }
}

// Application ID 636261
// Application Name Meloquiz dev
// Secret Key bb7570fe08f99a0b2b4eaef5bf549ce7
// Application domain com.meloquiz
// Contact email
// Site url
