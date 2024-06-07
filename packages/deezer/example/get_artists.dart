// ignore_for_file: avoid_print

import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';

import 'get_common.dart';

Future<void> main() async {
  await readArtist('27');
  await readArtist('01234567890123');
}

Future<void> readArtist(String id) async {
  var name = 'artist_$id.json';
  try {
    var map = await api.getArtistRaw(id);
    await writeFile(name, jsonPretty(map)!);
  } on DeezerApiException catch (e) {
    await writeFile(name, jsonPretty(e.rawBody ?? '')!);
    print(e);
  }
}
