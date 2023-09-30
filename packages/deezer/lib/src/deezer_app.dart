import 'package:cv/cv.dart';

class DeezerAppInfo extends CvModelBase {
  final id = CvField<String>('id');
  final secretKey = CvField<String>('secretKey');
  final domain = CvField<String>('domain');
  @override
  late final fields = <CvField>[id, secretKey, domain];
}
