// ignore_for_file: avoid_print

import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

import 'get_common.dart';

Future<void> main() async {
  debugDeezerApi = true;
  await readPlaylistTracks('27');
  await readPlaylistTracks('908622995');
  await readPlaylistTracks('1102638422212');
  await readPlaylistTracks('7424361304');
  await readPlaylistTracks('260764721');
}

Future<void> readPlaylistTracks(String id) async {
  var name = 'playlist_${id}_tracks.json';
  try {
    var map = await api.getPlaylistTracksRaw(id);
    await writeFile(name, jsonPretty(map)!);
  } on DeezerApiException catch (e) {
    await writeFile(name, jsonPretty(e.rawBody ?? '')!);
    print(e);
  }
}
