import 'package:cv/cv.dart';

import 'deezer_object.dart';

class DeezerAlbum extends CvDeezerObject {
  final title = CvField<String>('title');

  /// 56x56
  final coverSmall = CvField<String>('cover_small');

  /// 250x250
  final coverMedium = CvField<String>('cover_medium');

  @override
  late final fields = <CvField>[id, title, coverSmall, coverMedium];
}
