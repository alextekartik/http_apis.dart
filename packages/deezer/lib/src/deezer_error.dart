import 'package:cv/cv.dart';

class DeezerErrorInfo extends CvModelBase {
  final type = CvField<String>('type');
  final code = CvField<int>('code');
  final message = CvField<String>('message');
  @override
  late final fields = <CvField>[type, code, message];
}

class DeezerError extends CvModelBase {
  final error = CvModelField<DeezerErrorInfo>('error');
  @override
  late final fields = <CvField>[error];
}
