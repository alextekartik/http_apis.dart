import 'package:cv/cv.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';

class DeezerPlaylist extends CvDeezerObject {
  final title = CvField<String>('title');
  final description = CvField<String>('description');

  /// 120x120
  final picture = CvField<String>('picture');

  /// 56x56
  final pictureSmall = CvField<String>('picture_small');

  /// 250x250
  final pictureMedium = CvField<String>('picture_medium');
  final tracks = CvModelField<DeezerPlaylistTracks>('tracks');

  @override
  List<CvField> get fields => [
    id,
    title,
    description,
    picture,
    pictureSmall,
    pictureMedium,
    tracks,
  ];
}

class DeezerPlaylistTracks extends CvModelBase {
  final list = CvModelListField<DeezerTrack>('data');

  @override
  List<CvField> get fields => [list];
}
