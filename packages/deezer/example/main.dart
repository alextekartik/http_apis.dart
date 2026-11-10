// ignore_for_file: avoid_print

// Public Deezer data, no account: an artist, an album, a playlist with its
// tracks, the json of a field the models do not keep, and an error.
//
//   dart run example/main.dart
import 'package:tekartik_deezer_api/deezer_api.dart';

Future<void> main() async {
  var api = DeezerApi();

  var artist = await api.getArtist('27');
  print('artist ${artist.id.v}: ${artist.name.v}');

  var album = await api.getAlbum('302127');
  print('album ${album.id.v}: ${album.title.v} ${album.coverMedium.v}');

  // The models keep a few fields: the raw map has them all.
  var albumMap = await api.getAlbumRaw('302127');
  print('released ${albumMap['release_date']}');

  var playlist = await api.getPlaylist('260764721');
  print('playlist ${playlist.title.v}');
  for (var track in playlist.tracks.v?.list.v ?? <DeezerTrack>[]) {
    print('  ${track.title.v} by ${track.artist.v?.name.v}');
  }

  try {
    await api.getArtist('1234567891012');
  } on DeezerApiException catch (e) {
    // Deezer answers 200 with {"error": {...}} for an unknown id.
    print('error ${e.errorInfo?.type.v}: ${e.errorInfo?.message.v}');
  }
}
