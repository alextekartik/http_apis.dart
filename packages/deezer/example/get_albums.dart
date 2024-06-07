// ignore_for_file: avoid_print

import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

import 'get_common.dart';

Future<void> main() async {
  debugDeezerApi = true;
  await readAlbum('27');
  await readAlbum('302127');
}

Future<void> readAlbum(String id) async {
  var name = 'album_$id.json';
  try {
    var map = await api.getAlbumRaw(id);
    await writeFile(name, jsonPretty(map)!);
  } on DeezerApiException catch (e) {
    await writeFile(name, jsonPretty(e.rawBody ?? '')!);
    print(e);
  }
}
