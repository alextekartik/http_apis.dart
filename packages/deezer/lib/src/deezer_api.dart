import 'package:path/path.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';
import 'package:tekartik_deezer_api/src/platform/jsonp.dart';

import 'deezer_auth_client.dart';

var debugDeezerApi = false;

extension UriJsonp on Uri {
  Uri withJsonp() => replace(
      queryParameters: Map<String, Object?>.from(queryParameters)
        ..['output'] = 'jsonp');
}

class DeezerApi {
  final String? code;
  final String? accessToken;
  final DeezerApiOptions? options;
  final bool useJsonp;

  late final _authClient = DeezerAuthClient(this);

  @visibleForTesting
  set authToken(String authToken) {
    _authClient.authToken = authToken;
  }

  DeezerApi(
      {this.code,
      this.accessToken,
      this.options,

      /// Web only to go around CORS, automatically set to true when running on the web
      bool? useJsonp})
      : useJsonp = useJsonp ?? needJsonp {
    // assert(code != null || accessToken != null);
    initDeezerCvBuilders();
  }

  final _baseUrl = Uri.parse('https://api.deezer.com/2.0');
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
    if (useJsonp) {
      // Unauth only
      uri = uri.withJsonp();
      return asModel((await jsonpRequest(uri)) as Map);
    } else {
      var body = await _authClient.read(uri);
      return jsonDecode(body) as Model;
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

  Future<Model> getAlbumRaw(String id) async {
    var uri = _withAppendedPath('album/$id');
    return await _readMap(uri);
  }

  Future<String?> getAccessToken() async {
    return await _authClient.getAccessToken();
  }
}

// Application ID 636261
// Application Name Meloquiz dev
// Secret Key bb7570fe08f99a0b2b4eaef5bf549ce7
// Application domain com.meloquiz
// Contact email
// Site url
