import 'package:cv/cv.dart';

/// https://stripe.com/docs/api/products/create
class StripeApiProductCreate extends CvModelBase {
  final name = CvField<String>('name');
  final description = CvField<String>('description');

  @override
  List<CvField<Object?>> get fields => [name, description];
}
