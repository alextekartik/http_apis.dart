import 'package:cv/cv.dart';

import 'stripe_models.dart';

mixin StripeApiPriceMixin {
  final productId = CvField<String>('product');
  final currency = CvField<String>('currency');
  final nickname = CvField<String>('nickname');

  /// cents
  final amount = CvField<int>('unit_amount');
  final recurring = CvModelField<StringApiPriceRecurring>('recurring');

  List<CvField<Object?>> get priceMixinFields => [
        productId,
        nickname,
        currency,
        amount,
        recurring,
      ];
}

/// https://stripe.com/docs/api/prices/create
class StripeApiPriceCreate extends CvModelBase
    with StripeApiPriceMixin, StripeApiMetadataMixin {
  @override
  List<CvField<Object?>> get fields =>
      [...priceMixinFields, ...metadataMixinFields];
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
class StringApiPriceRecurring extends CvModelBase {
  final interval = CvField<String>('interval');
  final intervalCount = CvField<int>('interval_count');

  @override
  List<CvField<Object?>> get fields => [interval, intervalCount];
}
