// ignore_for_file: avoid_print

import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

import 'get_common.dart';

Future<void> main() async {
  debugDeezerApi = true;
  await readPlaylist('27');
  await readPlaylist('908622995');
  await readPlaylist('1102638422212');
  await readPlaylist('7424361304');
  await readPlaylist('260764721');
}

Future<void> readPlaylist(String id) async {
  var name = 'playlist_$id.json';
  try {
    var map = await api.getPlaylistRaw(id);
    await writeFile(name, jsonPretty(map)!);
  } on DeezerApiException catch (e) {
    await writeFile(name, jsonPretty(e.rawBody ?? '')!);
    print(e);
  }
}
