import 'package:cv/cv.dart';

import 'stripe_models.dart';

mixin StripeApiPriceCreateUpdateMixin {
  final nickname = CvField<String>('nickname');
  final active = CvField<bool>('active');

  List<CvField<Object?>> get createUpdatePriceMixinFields => [
        nickname,
        active,
      ];
}

mixin StripeApiPriceMixin {
  final productId = CvField<String>('product');
  final currency = CvField<String>('currency');

  /// cents
  final amount = CvField<int>('unit_amount');
  final recurring = CvModelField<StringApiPriceRecurring>('recurring');

  List<CvField<Object?>> get priceMixinFields => [
        productId,
        currency,
        amount,
        recurring,
      ];
}

/// https://stripe.com/docs/api/prices/create
class StripeApiPriceCreate extends CvModelBase
    with
        StripeApiPriceCreateUpdateMixin,
        StripeApiPriceMixin,
        StripeApiMetadataMixin {
  @override
  List<CvField<Object?>> get fields => [
        ...createUpdatePriceMixinFields,
        ...priceMixinFields,
        ...metadataMixinFields
      ];
}

/// https://stripe.com/docs/api/prices/update
class StripeApiPriceUpdate extends CvModelBase
    with StripeApiPriceCreateUpdateMixin, StripeApiMetadataMixin {
  @override
  List<CvField<Object?>> get fields =>
      [...createUpdatePriceMixinFields, ...metadataMixinFields];
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
class StringApiPriceRecurring extends CvModelBase {
  final interval = CvField<String>('interval');
  final intervalCount = CvField<int>('interval_count');

  @override
  List<CvField<Object?>> get fields => [interval, intervalCount];
}
