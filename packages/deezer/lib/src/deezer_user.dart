import 'package:cv/cv.dart';

import 'deezer_object.dart';

class DeezerUser extends CvDeezerObject {
  final name = CvField<String>('name');
  @override
  late final fields = <CvField>[id, name];
}
