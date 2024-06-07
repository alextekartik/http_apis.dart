// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';

var api = DeezerApi();

var dataTopDirectory = Directory(join('doc', 'json', 'unlogged'));

File dataFile(String name) => File(join(dataTopDirectory.path, name));

Future<void> writeFile(String name, String content) async {
  var file = dataFile(name);
  print(file);
  if (!dataTopDirectory.existsSync()) {
    await dataTopDirectory.create(recursive: true);
  }
  await file.writeAsString(content);
}
