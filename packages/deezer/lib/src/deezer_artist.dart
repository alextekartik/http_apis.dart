import 'package:cv/cv.dart';

import 'deezer_object.dart';

/// For artist in track we have only the following fields:
/// "artist": {
//           "id": 1719,
//           "name": "Siouxsie and The Banshees",
//           "link": "http://www.deezer.com/artist/1719",
//           "tracklist": "http://api.deezer.com/2.0/artist/1719/top?limit=50",
//           "type": "artist"
//         },
class DeezerArtist extends CvDeezerObject {
  final name = CvField<String>('name');

  /// Below not in track artist
  /// 120x120
  final picture = CvField<String>('picture');

  /// 56x56
  final pictureSmall = CvField<String>('picture_small');

  /// 250x250
  final pictureMedium = CvField<String>('picture_medium');
  @override
  late final fields = <CvField>[id, name, picture, pictureSmall, pictureMedium];
}
