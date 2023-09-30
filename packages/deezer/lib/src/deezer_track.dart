import 'package:cv/cv.dart';

import 'deezer_album.dart';
import 'deezer_artist.dart';
import 'deezer_object.dart';

class DeezerTrack extends CvDeezerObject {
  final title = CvField<String>('title');
  final preview = CvField<String>('preview');
  final artist = CvModelField<DeezerArtist>('artist');
  final album = CvModelField<DeezerAlbum>('album');

  @override
  late final fields = <CvField>[id, title, preview, artist, album];
}
