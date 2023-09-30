import 'package:cv/cv.dart';
import 'package:tekartik_deezer_api/deezer_api.dart';

void initDeezerCvBuilders() {
  cvAddConstructor(DeezerArtist.new);
  cvAddConstructor(DeezerTrack.new);
  cvAddConstructor(DeezerAlbum.new);
  cvAddConstructor(DeezerUser.new);
  cvAddConstructor(DeezerPlaylist.new);
  cvAddConstructor(DeezerPlaylistTracks.new);
  cvAddConstructor(DeezerError.new);
  cvAddConstructor(DeezerErrorInfo.new);
  cvAddConstructor(DeezerAppInfo.new);
}

class CvDeezerObject extends CvModelBase {
  final id = CvField<String>('id');

  @override
  List<CvField> get fields => [id];
}
