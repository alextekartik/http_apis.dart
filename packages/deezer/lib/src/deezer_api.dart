import 'package:path/path.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';
import 'package:tekartik_deezer_api/src/platform/jsonp.dart';

import 'deezer_auth_client.dart';
import 'deezer_json.dart';

var debugDeezerApi = false; // devWarning(true);

extension UriJsonp on Uri {
  Uri withJsonp() => replace(
    queryParameters: Map<String, Object?>.from(queryParameters)
      ..['output'] = 'jsonp',
  );
}

class DeezerApi {
  static const userIdMe = 'me';

  final String? code;
  final String? accessToken;
  final DeezerApiOptions? options;
  final bool useJsonp;

  late final _authClient = DeezerAuthClient(this);

  @visibleForTesting
  set authToken(String authToken) {
    _authClient.authToken = authToken;
  }

  DeezerApi({
    this.code,
    this.accessToken,
    this.options,

    /// Web only to go around CORS, automatically set to true when running on the web
    bool? useJsonp,
  }) : useJsonp = useJsonp ?? needJsonp {
    // assert(code != null || accessToken != null);
    initDeezerCvBuilders();
    if (debugDeezerApi) {
      print(
        'DeezerApi code: $code accessToken: $accessToken, useJsonp: ${this.useJsonp}',
      );
    }
  }

  final _baseUrl = Uri.parse('https://api.deezer.com/2.0');

  /// Get current user, need access token
  Future<DeezerUser> getMe() {
    return getUser(userIdMe);
  }

  /// Need access token.
  Future<DeezerUser> getUser(String userId) async {
    var uri = _withAppendedPath('user/$userId');
    var body = await _authClient.readString(uri);
    return body.cv<DeezerUser>();
  }

  Uri _withAppendedPath(String path) {
    var uri = _baseUrl.replace(path: url.join(_baseUrl.path, path));
    return uri;
  }

  Future<DeezerArtist> getArtist(String id) async {
    return (await getArtistRaw(id)).cv<DeezerArtist>();
  }

  Future<Object> readAny(Uri uri) => _readJson(uri);

  /// Reads a json map or list (through JSONP on the web).
  ///
  /// A Deezer error throws a [DeezerApiException] on both paths (the auth
  /// client checks it on io).
  Future<Object> _readJson(Uri uri) async {
    if (debugDeezerApi) {
      print('uri: $uri');
    }
    try {
      if (useJsonp) {
        // Unauth only
        var result = await jsonpRequest(uri.withJsonp());
        if (debugDeezerApi) {
          print('dzresult ${result.runtimeType} $result');
        }
        return deezerCheckJsonResult(result);
      } else {
        var body = await _authClient.read(uri);
        return jsonDecode(body) as Object;
      }
    } catch (e) {
      if (debugDeezerApi) {
        print('error: $e for $uri');
      }
      rethrow;
    }
  }

  Future<Model> _readMap(Uri uri) async => asModel(await _readJson(uri) as Map);

  Future<String> readString(Uri uri) async {
    if (useJsonp) {
      var result = await _readJson(uri);
      if (result is Map) {
        return jsonEncode(result);
      }
      return result.toString();
    } else {
      if (debugDeezerApi) {
        print('dzuri: $uri');
      }
      return await _authClient.read(uri);
    }
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

  /// Need access token? tracks not available here.
  Future<List<DeezerPlaylist>> getUserPlaylists(String userId) async {
    var uri = _withAppendedPath('user/$userId/playlists');
    var result = await _readJson(uri);
    if (result is Map && result.containsKey('data')) {
      var data = result['data'] as List;
      return data.map((e) => e as Map).toList().cv<DeezerPlaylist>();
    } else if (result is List) {
      return result.cast<Map<Object?, Object?>>().cv<DeezerPlaylist>();
    }
    throw UnsupportedError('invalid result ${result.runtimeType} $result');
  }

  Future<List<DeezerPlaylist>> getMyPlaylists() {
    return getUserPlaylists(userIdMe);
  }

  Future<Model> getAlbumRaw(String id) async {
    var uri = _withAppendedPath('album/$id');
    return await _readMap(uri);
  }

  Future<String?> getAccessToken() async {
    return await _authClient.getAccessToken();
  }
}
