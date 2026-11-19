import 'package:cv/cv.dart';

import 'price_options.dart';
import 'stripe_models.dart';

/// `default_price_data` of a product creation: its first price, made the
/// default one.
class StripeApiProductDefaultPriceData extends CvModelBase {
  /// `eur`...
  final currency = CvField<String>('currency');

  /// Cents.
  final amount = CvField<int>('unit_amount');

  /// A recurring price when set.
  final recurring = CvModelField<StringApiPriceRecurring>('recurring');

  @override
  List<CvField<Object?>> get fields => [currency, amount, recurring];
}

/// https://stripe.com/docs/api/products/create
class StripeApiProductCreate extends CvModelBase with StripeApiMetadataMixin {
  final name = CvField<String>('name');
  final description = CvField<String>('description');

  /// The tax code of Stripe Tax (`txcd_10000000`: electronically supplied
  /// services), the account's default when null.
  final taxCode = CvField<String>('tax_code');

  /// false to create it archived.
  final active = CvField<bool>('active');

  /// Its first price, made the default one.
  final defaultPriceData = CvModelField<StripeApiProductDefaultPriceData>(
    'default_price_data',
  );

  @override
  List<CvField<Object?>> get fields => [
    name,
    description,
    taxCode,
    active,
    defaultPriceData,
    ...metadataMixinFields,
  ];
}

/// https://docs.stripe.com/api/products/update
class StripeApiProductUpdate extends CvModelBase with StripeApiMetadataMixin {
  final name = CvField<String>('name');
  final description = CvField<String>('description');

  /// See [StripeApiProductCreate.taxCode].
  final taxCode = CvField<String>('tax_code');

  /// false to archive it, true to restore it.
  final active = CvField<bool>('active');

  /// The default price id.
  final defaultPrice = CvField<String>('default_price');

  @override
  List<CvField<Object?>> get fields => [
    name,
    description,
    taxCode,
    active,
    defaultPrice,
    ...metadataMixinFields,
  ];
}
