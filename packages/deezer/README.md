# tekartik_deezer_api

A small read only client of the [Deezer API](https://developers.deezer.com/api)
(`https://api.deezer.com/2.0`): artists, albums, playlists, users and their
playlists. Answers are `cv` models (`field.v`), errors a
`DeezerApiException`.

Pure Dart: Dart VM, Flutter (every platform) and the web. On the web the
requests go through JSONP (api.deezer.com sends no CORS headers), chosen
automatically.

## Getting started

Git package, not on pub.dev:

```yaml
dependencies:
  tekartik_deezer_api:
    git:
      url: https://github.com/alextekartik/http_apis.dart
      path: packages/deezer
```

The public endpoints need no account:

```dart
import 'package:tekartik_deezer_api/deezer_api.dart';

Future<void> main() async {
  var api = DeezerApi();

  var artist = await api.getArtist('27');
  print('${artist.name.v} ${artist.pictureMedium.v}');

  var playlist = await api.getPlaylist('260764721');
  for (var track in playlist.tracks.v?.list.v ?? <DeezerTrack>[]) {
    print('${track.title.v} by ${track.artist.v?.name.v}: ${track.preview.v}');
  }

  try {
    await api.getArtist('1234567891012');
  } on DeezerApiException catch (e) {
    // Deezer answers 200 with {"error": {...}} for an unknown id.
    print('${e.errorInfo?.type.v}: ${e.errorInfo?.message.v}');
  }
}
```

More in [example/main.dart](example/main.dart) (the other files of `example/`
record the json answers of `doc/json/`).

## What to use

| API | What |
|---|---|
| `getArtist`, `getAlbum`, `getPlaylist(id)` | Public objects, as `DeezerArtist`, `DeezerAlbum`, `DeezerPlaylist` (a few fields each). |
| `getArtistRaw`, `getAlbumRaw`, `getPlaylistRaw`, `getPlaylistTracksRaw` | The whole json map (`Model`) when the models lack a field. |
| `getMe`, `getUser(id)`, `getUserPlaylists(id)`, `getMyPlaylists()` | User data: an access token is needed for `me`. |
| `readAny(uri)`, `readString(uri)` | Any other endpoint, decoded or raw. |
| `DeezerApi(accessToken:)`, `DeezerApi(code:, options:)`, `getAccessToken()` | OAuth: a token you have, or a code exchanged once for a token. |
| `DeezerApiException` | `httpStatusCode`, `errorInfo` (`type`, `code`, `message`), `rawBody`. |

## Good to know

- Lists are paged by Deezer (25 items): `getUserPlaylists` and
  `getMyPlaylists` return the first 25 only. Read the next pages with
  `readAny` and the `index` parameter
  (`https://api.deezer.com/2.0/user/<id>/playlists?index=25`).
- `getPlaylist(id)` embeds the tracks; `getPlaylistTracks` answers
  `{"data": [...]}` without the playlist fields: use `getPlaylistTracksRaw`.
- Ids are strings in the models (Deezer sends numbers). Pass plain ids: they
  are appended to the url path as is.
- Authentication belongs on a server or a native app: the code exchange needs
  the app secret, which never goes in a web or mobile app. On the web only
  `getMe` and `getUser` send the access token (in the JSONP url);
  `getUserPlaylists`, `getMyPlaylists` and `readAny` do not.
- A code can be exchanged once: keep one `DeezerApi` per code
  (`getAccessToken()` returns the token it was exchanged for), then build the
  next ones with `accessToken:`.
- `debugDeezerApi = true` prints every url and answer, the token and the app
  secret of the code exchange included: keep it out of production logs.
- `useJsonp: true` on the VM throws `UnsupportedError`; `useJsonp: false` on
  the web fails on CORS.

Agent skill: [tekartik-deezer-api-client](skills/tekartik-deezer-api-client/SKILL.md).
