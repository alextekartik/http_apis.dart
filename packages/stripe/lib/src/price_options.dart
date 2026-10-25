import 'package:cv/cv.dart';

import 'stripe_models.dart';

mixin StripeApiPriceCreateUpdateMixin {
  final nickname = CvField<String>('nickname');
  final active = CvField<bool>('active');

  List<CvField<Object?>> get createUpdatePriceMixinFields => [nickname, active];
}

mixin StripeApiPriceMixin {
  final productId = CvField<String>('product');
  final currency = CvField<String>('currency');

  /// cents
  final amount = CvField<int>('unit_amount');
  final recurring = CvModelField<StringApiPriceRecurring>('recurring');

  /// A key of your own to find the price ([StripeApiPriceListOptions]).
  final lookupKey = CvField<String>('lookup_key');

  /// `inclusive`, `exclusive` or `unspecified` (taxes).
  final taxBehavior = CvField<String>('tax_behavior');

  List<CvField<Object?>> get priceMixinFields => [
    productId,
    currency,
    amount,
    recurring,
    lookupKey,
    taxBehavior,
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
    ...metadataMixinFields,
  ];
}

/// https://stripe.com/docs/api/prices/update
class StripeApiPriceUpdate extends CvModelBase
    with StripeApiPriceCreateUpdateMixin, StripeApiMetadataMixin {
  @override
  List<CvField<Object?>> get fields => [
    ...createUpdatePriceMixinFields,
    ...metadataMixinFields,
  ];
}

/// https://docs.stripe.com/api/prices/list
class StripeApiPriceListOptions extends CvModelBase {
  /// The prices of these lookup keys.
  final lookupKeys = CvListField<String>('lookup_keys');

  /// Active ones only (true) or inactive ones only (false).
  final active = CvField<bool>('active');

  /// The prices of a product.
  final productId = CvField<String>('product');

  /// See [StripeApiProductListOptions.limit].
  final limit = CvField<int>('limit');

  @override
  List<CvField<Object?>> get fields => [lookupKeys, active, productId, limit];

  /// The query parameters (`lookup_keys[]` repeated).
  Map<String, Object> toQueryParameters() => {
    if (lookupKeys.v case var keys? when keys.isNotEmpty) 'lookup_keys[]': keys,
    if (active.v case var active?) 'active': '$active',
    'product': ?productId.v,
    if (limit.v case var limit?) 'limit': '$limit',
  };
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
class StringApiPriceRecurring extends CvModelBase {
  final interval = CvField<String>('interval');
  final intervalCount = CvField<int>('interval_count');

  @override
  List<CvField<Object?>> get fields => [interval, intervalCount];
}
