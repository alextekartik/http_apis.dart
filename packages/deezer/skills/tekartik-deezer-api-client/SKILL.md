---
name: tekartik-deezer-api-client
description: >-
  Use when reading the public Deezer REST API (api.deezer.com) from Dart or
  Flutter with tekartik_deezer_api: DeezerApi, getArtist, getAlbum,
  getPlaylist, getPlaylistTracks, getUser, getMe, getUserPlaylists,
  getMyPlaylists, the *Raw variants, readAny/readString, the cv models
  DeezerArtist, DeezerAlbum, DeezerTrack, DeezerPlaylist,
  DeezerPlaylistTracks, DeezerUser, DeezerError, DeezerAppInfo, error
  handling with DeezerApiException, OAuth with DeezerApiOptions and
  accessToken, and the jsonp/CORS workaround on the web (useJsonp).
---

# Deezer API client (tekartik_deezer_api)

`tekartik_deezer_api` is a thin read-only wrapper over the Deezer REST API
v2.0 (`https://api.deezer.com/2.0`). Responses are decoded into `cv` models
(`package:cv`), so every field is a `CvField` read through `.v`.

## Guidelines

* Dependency (git, not on pub.dev). Add `cv` too, the models are `cv` models:
  ```yaml
  dependencies:
    tekartik_deezer_api:
      git:
        url: https://github.com/alextekartik/http_apis.dart
        path: packages/deezer
      version: '>=0.1.0'
    cv: '>=1.1.0+4'
  ```
* Single import: `package:tekartik_deezer_api/deezer_api.dart`. It exports the
  api, the models, the exception and `initDeezerCvBuilders()`. Add
  `package:cv/cv_json.dart` when you need `toMap()`, `.cv<T>()` or the `Model`
  type (that is what the `*Raw` methods return). Never import
  `package:tekartik_deezer_api/src/...` from application code.
* Build one `DeezerApi(...)` and reuse it. All constructor parameters are
  optional: `DeezerApi()` reads public endpoints anonymously. The constructor
  calls `initDeezerCvBuilders()` for you.
* Public (no token needed): `getArtist(id)`, `getAlbum(id)`, `getPlaylist(id)`,
  `getPlaylistTracks(id)`. Each has a `*Raw` twin (`getArtistRaw`,
  `getAlbumRaw`, `getPlaylistRaw`, `getPlaylistTracksRaw`) returning the
  undecoded `Model` (json map) - use it when you need fields the models drop.
* Token needed: `getMe()`, `getUser(userId)`, `getUserPlaylists(userId)`,
  `getMyPlaylists()`. `DeezerApi.userIdMe` is the `'me'` constant.
  Without a token these return a `DeezerError`, surfaced as a
  `DeezerApiException` with `errorInfo.type.v == 'OAuthException'`.
* Two ways to authenticate, both on the constructor:
  `DeezerApi(accessToken: '<deezer-access-token>')` when you already have a
  token, or `DeezerApi(code: '<oauth-code>', options: DeezerApiOptions(appId:,
  appSecret:, redirectUri:))` to let the client exchange the OAuth code
  (`connect.deezer.com/oauth/access_token.php`) on the first call.
  `getAccessToken()` returns the resulting token (null if the exchange
  failed). Keep `appSecret` out of the source: read it from an environment
  variable or an untracked file.
* The models keep only a few fields of each Deezer object:
  `DeezerArtist` = `id`, `name`, `picture`, `pictureSmall` (56x56),
  `pictureMedium` (250x250); `DeezerAlbum` = `id`, `title`, `coverSmall`,
  `coverMedium`; `DeezerTrack` = `id`, `title`, `preview` (mp3 url),
  `artist`, `album`; `DeezerPlaylist` = `id`, `title`, `description`,
  `picture`, `pictureSmall`, `pictureMedium`, `tracks`;
  `DeezerUser` = `id`, `name`. Ids are strings even though Deezer sends
  integers. Read values with `.v` (nullable), sub models with `.v!`.
* Playlist tracks: `getPlaylist(id)` fills `playlist.tracks.v!.list.v!`
  (a `List<DeezerTrack>`) from the embedded `tracks.data`. `getPlaylistTracks`
  hits `playlist/<id>/tracks`, whose response is `{"data": [...]}` with no
  playlist envelope, so the returned `DeezerPlaylist` has empty fields: for
  that endpoint use `getPlaylistTracksRaw(id)` and read its `data` list
  yourself, or stay on `getPlaylist(id)`.
* Errors: every failure is a `DeezerApiException` with `httpStatusCode`,
  `rawBody` (the body as received) and `errorInfo` (`DeezerErrorInfo` with
  `type`, `code`, `message`) when Deezer answered a json error. Deezer answers
  `200` with an error body for unknown ids, so always catch it.
* Escape hatches for endpoints the wrapper does not cover:
  `readAny(uri)` returns the decoded json (`Map` or `List`) and
  `readString(uri)` the raw body, both going through the same auth/jsonp path.
  Build the uri yourself from `https://api.deezer.com/2.0/...`.
* Web/CORS: on a browser target `useJsonp` defaults to `true` (from
  `needJsonp`) and requests go through a jsonp `<script>` tag with
  `output=jsonp` (`uri.withJsonp()`), because api.deezer.com sends no CORS
  headers. Jsonp cannot carry the access token, so on the web only the public
  endpoints work; do authenticated calls from a server or from native.
  Forcing `DeezerApi(useJsonp: false)` on the web makes every call fail on
  CORS, and `useJsonp: true` on the VM throws `UnsupportedError`.
* Debugging: set the top-level `debugDeezerApi = true` to print every uri,
  response and error.
* Tests: model/json tests run anywhere, but call `initDeezerCvBuilders()` in
  `setUpAll` (or at the top of `main`) before any `.cv<DeezerTrack>()` when no
  `DeezerApi` has been created. Tests that really hit Deezer must be
  `@TestOn('browser')` and run with `dart test -p chrome` (that is what this
  package's `dart_test.yaml` does), since jsonp is the only way in.

## Examples

### Public reads, with error handling

```dart
import 'package:tekartik_deezer_api/deezer_api.dart';

Future<void> main() async {
  var api = DeezerApi(); // anonymous: public endpoints only
  // debugDeezerApi = true; // prints every request/response

  var artist = await api.getArtist('27');
  print('${artist.id.v} ${artist.name.v} ${artist.pictureMedium.v}');

  var album = await api.getAlbum('302127');
  print('${album.title.v} ${album.coverSmall.v}');

  var playlist = await api.getPlaylist('260764721');
  print('${playlist.title.v} ${playlist.description.v}');
  for (var track in playlist.tracks.v?.list.v ?? <DeezerTrack>[]) {
    print('${track.title.v} / ${track.artist.v?.name.v} -> ${track.preview.v}');
  }

  try {
    await api.getArtist('1234567891012');
  } on DeezerApiException catch (e) {
    // Deezer answers 200 with {"error": {...}} for unknown ids.
    print('${e.httpStatusCode} ${e.errorInfo?.type.v}: ${e.errorInfo?.message.v}');
  }
}
```

### Raw json when the models drop the fields you need

```dart
import 'dart:convert';

import 'package:cv/cv_json.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';

Future<void> dumpAlbum(String id) async {
  var api = DeezerApi();
  var map = await api.getAlbumRaw(id); // a cv Model (Map<String, Object?>)
  print(map['release_date']); // not in DeezerAlbum
  print(jsonEncode(map));

  // `playlist/<id>/tracks` answers {"data": [...]} with no playlist envelope.
  var raw = await api.getPlaylistTracksRaw('260764721');
  var tracks = (raw['data'] as List).cast<Map<dynamic, dynamic>>().cv<DeezerTrack>();
  for (var track in tracks) {
    print('${track.id.v} ${track.title.v}');
  }

  // Any other endpoint of the v2.0 api.
  var search = await api.readAny(
    Uri.parse('https://api.deezer.com/2.0/search?q=daft+punk'),
  );
  print(search);
}
```

### Authenticated calls (native or server side)

```dart
import 'dart:io';

import 'package:tekartik_deezer_api/deezer_api.dart';

Future<void> main() async {
  // Never hardcode the token: read it from the environment.
  var token = Platform.environment['DEEZER_ACCESS_TOKEN']!;
  var api = DeezerApi(accessToken: token);

  var me = await api.getMe(); // same as getUser(DeezerApi.userIdMe)
  print('${me.id.v} ${me.name.v}');

  for (var playlist in await api.getMyPlaylists()) {
    // Playlists listed here carry no tracks: fetch them one by one.
    var full = await api.getPlaylist(playlist.id.v!);
    print('${full.title.v}: ${full.tracks.v?.list.v?.length ?? 0} track(s)');
  }
}
```

### Exchanging an OAuth code for an access token

```dart
import 'dart:io';

import 'package:tekartik_deezer_api/deezer_api.dart';

/// [code] is the `code` query parameter Deezer redirected back with.
Future<String?> exchange(String code) async {
  var env = Platform.environment;
  var api = DeezerApi(
    code: code,
    options: DeezerApiOptions(
      appId: env['DEEZER_APP_ID'] ?? '<app-id>',
      appSecret: env['DEEZER_APP_SECRET'] ?? '<app-secret>',
      redirectUri: 'https://example.com/deezer/callback',
    ),
  );
  var accessToken = await api.getAccessToken();
  if (accessToken == null) {
    throw StateError('code exchange failed (expired or wrong app secret)');
  }
  // The same api instance is now authenticated.
  print((await api.getMe()).name.v);
  return accessToken;
}
```

### Parsing stored json in a test

```dart
import 'package:cv/cv_json.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() {
    // Needed before any .cv<...>() when no DeezerApi was created.
    initDeezerCvBuilders();
  });

  test('track', () {
    var track = {
      'id': '3135556',
      'title': 'Harder, Better, Faster, Stronger',
      'preview': 'https://cdns-preview-d.dzcdn.net/stream/demo.mp3',
      'artist': {'id': '27', 'name': 'Daft Punk'},
      'album': {'id': '302127', 'title': 'Discovery'},
    }.cv<DeezerTrack>();
    expect(track.artist.v!.name.v, 'Daft Punk');
    expect(track.album.v!.title.v, 'Discovery');
  });

  test('error', () {
    var error = {
      'error': {'type': 'OAuthException', 'message': 'no token', 'code': 200},
    }.cv<DeezerError>();
    expect(error.error.v!.type.v, 'OAuthException');
    expect(error.error.v!.code.v, 200);
  });
}
```
