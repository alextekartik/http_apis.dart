@TestOn('browser')
library;
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/import.dart';
import 'package:test/test.dart';

void main() {
  // debugDeezerApi = devWarning(true);
  setUpAll(() {
    initDeezerCvBuilders();
  });

  test('Artist', () async {
    var deezerApi = DeezerApi();
    var artist = await deezerApi.getArtist('27');
    print(jsonPretty(artist.toMap()));
    // {
    //   "id": "27",
    //   "name": "Daft Punk",
    //   "picture": "http://api.deezer.com/2.0/artist/27/image"
    // }

    // Missing
    try {
      artist = await deezerApi.getArtist('1234567891012');
    } catch (e) {
      expect(e, isA<DeezerApiException>());
    }
  });

  test('Playlist', () async {
    var deezerApi = DeezerApi();
    var artist = await deezerApi.getPlaylist('260764721');
    print(jsonPretty(artist.toMap()));
    // {
    //   "id": "260764721",
    //   "title": "1 item",
    //   "picture": "http://api.deezer.com/2.0/playlist/260764721/image",
    //   "picture_small": "http://e-cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/56x56-000000-80-0-0.jpg",
    //   "picture_medium": "http://e-cdn-images.dzcdn.net/images/cover/aace835cee2c52614f55282b6081e5c6/250x250-000000-80-0-0.jpg",
    //   "tracks": {
    //     "data": [
    //       {
    //         "id": "937330",
    //         "title": "Oxford Comma",
    //         "preview": "http://cdn-preview-1.deezer.com/stream/c-128660c09ef7373f9919e2150cc4a7bd-3.mp3",
    //         "artist": {
    //           "id": "75781",
    //           "name": "Vampire Weekend"
    //         },
    //         "album": {
    //           "id": "105411",
    //           "title": "Vampire Weekend",
    //           "cover_small": "http://e-cdn-images.dzcdn.net/images/cover/6fc963e3e5bd489dd82b0e02c3122792/56x56-000000-80-0-0.jpg",
    //           "cover_medium": "http://e-cdn-images.dzcdn.net/images/cover/6fc963e3e5bd489dd82b0e02c3122792/250x250-000000-80-0-0.jpg"
    //         }
    //       }
    //     ]
    //   }
    // }
  });
}
