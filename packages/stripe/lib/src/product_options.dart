import 'package:cv/cv.dart';

/// https://stripe.com/docs/api/products/create
class StripeApiProductCreate extends CvModelBase {
  final name = CvField<String>('name');
  final description = CvField<String>('description');

  /// The tax code of Stripe Tax (`txcd_10000000`: electronically supplied
  /// services), the account's default when null.
  final taxCode = CvField<String>('tax_code');

  @override
  List<CvField<Object?>> get fields => [name, description, taxCode];
}

/// https://docs.stripe.com/api/products/update
class StripeApiProductUpdate extends CvModelBase {
  final name = CvField<String>('name');
  final description = CvField<String>('description');

  /// See [StripeApiProductCreate.taxCode].
  final taxCode = CvField<String>('tax_code');

  @override
  List<CvField<Object?>> get fields => [name, description, taxCode];
}
