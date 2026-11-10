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

/// Read only client of the Deezer API (`https://api.deezer.com/2.0`).
///
/// `DeezerApi()` reads the public endpoints. Every failure throws a
/// [DeezerApiException] (Deezer answers 200 with an error body for an
/// unknown id). On the web the requests go through JSONP.
class DeezerApi {
  /// The user id of the authenticated user (`user/me`).
  static const userIdMe = 'me';

  /// An OAuth code to exchange (once) for an access token, with [options].
  final String? code;

  /// An access token the requests carry.
  final String? accessToken;

  /// The app id and secret needed to exchange a [code] (server side only).
  final DeezerApiOptions? options;

  /// Whether the requests go through JSONP (the default on the web).
  final bool useJsonp;

  late final _authClient = DeezerAuthClient(this);

  @visibleForTesting
  set authToken(String authToken) {
    _authClient.authToken = authToken;
  }

  /// A client: anonymous, with an [accessToken], or with a [code] and the
  /// [options] to exchange it.
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

  /// The authenticated user; needs an access token (or a code).
  Future<DeezerUser> getMe() {
    return getUser(userIdMe);
  }

  /// A user ([userIdMe] needs an access token).
  Future<DeezerUser> getUser(String userId) async {
    var uri = _withAppendedPath('user/$userId');
    var body = await _authClient.readString(uri);
    return body.cv<DeezerUser>();
  }

  Uri _withAppendedPath(String path) {
    var uri = _baseUrl.replace(path: url.join(_baseUrl.path, path));
    return uri;
  }

  /// An artist (`id`, `name`, pictures).
  Future<DeezerArtist> getArtist(String id) async {
    return (await getArtistRaw(id)).cv<DeezerArtist>();
  }

  /// The decoded json (a `Map` or a `List`) of any endpoint [uri].
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

  /// The body of any endpoint [uri] (on the web, a json map re-encoded).
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

  /// The whole json map of an artist.
  Future<Model> getArtistRaw(String id) async {
    var uri = _withAppendedPath('artist/$id');
    return await _readMap(uri);
  }

  /// A playlist with its tracks (`tracks.v!.list.v`).
  Future<DeezerPlaylist> getPlaylist(String id) async {
    return (await getPlaylistRaw(id)).cv<DeezerPlaylist>();
  }

  /// The whole json map of a playlist.
  Future<Model> getPlaylistRaw(String id) async {
    var uri = _withAppendedPath('playlist/$id');
    return await _readMap(uri);
  }

  /// `playlist/<id>/tracks` answers `{"data": [...]}` without the playlist
  /// fields (and paged, 25 tracks): prefer [getPlaylist] or
  /// [getPlaylistTracksRaw].
  Future<DeezerPlaylist> getPlaylistTracks(String id) async {
    return (await getPlaylistTracksRaw(id)).cv<DeezerPlaylist>();
  }

  /// The json map of `playlist/<id>/tracks` (`data`, `total`, `next`).
  Future<Model> getPlaylistTracksRaw(String id) async {
    var uri = _withAppendedPath('playlist/$id/tracks');
    return await _readMap(uri);
  }

  /// An album (`id`, `title`, covers).
  Future<DeezerAlbum> getAlbum(String id) async {
    return (await getAlbumRaw(id)).cv<DeezerAlbum>();
  }

  /// The playlists of a user, without their tracks.
  ///
  /// The first page only (Deezer pages its lists by 25): read the next ones
  /// with [readAny] and `?index=25`, `?index=50`...
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

  /// The playlists of the authenticated user (first page, see
  /// [getUserPlaylists]).
  Future<List<DeezerPlaylist>> getMyPlaylists() {
    return getUserPlaylists(userIdMe);
  }

  /// The whole json map of an album.
  Future<Model> getAlbumRaw(String id) async {
    var uri = _withAppendedPath('album/$id');
    return await _readMap(uri);
  }

  /// The token the requests use: [accessToken], or the one [code] was
  /// exchanged for (exchanged once, then kept: a code is valid once).
  ///
  /// Null without token nor code, or when the exchange failed.
  Future<String?> getAccessToken() async {
    return await _authClient.getAccessToken();
  }
}
