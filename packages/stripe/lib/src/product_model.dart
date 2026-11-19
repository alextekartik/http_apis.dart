import 'package:cv/cv.dart';

import 'stripe_models.dart';

// {
//   "id": "price_1NzKqcJarQTbINzH3ONh99fm",
//   "object": "price",
//   "active": true,
//   "billing_scheme": "per_unit",
//   "created": 1696863258,
//   "currency": "eur",
//   "custom_unit_amount": null,
//   "livemode": false,
//   "lookup_key": null,
//   "metadata": {},
//   "nickname": null,
//   "product": "prod_OmtgJbSbudZ2hT",
//   "recurring": null,
//   "tax_behavior": "unspecified",
//   "tiers_mode": null,
//   "transform_quantity": null,
//   "type": "one_time",
//   "unit_amount": 987,
//   "unit_amount_decimal": "987"
// }
class StripeApiProduct extends CvModelBase with StripeApiMetadataMixin {
  final id = CvField<String>('id');
  final name = CvField<String>('name');
  final description = CvField<String>('description');

  /// The tax code of Stripe Tax, null for the account's default.
  final taxCode = CvField<String>('tax_code');

  /// false once archived.
  final active = CvField<bool>('active');

  /// The default price id (`price_...`), if any.
  final defaultPrice = CvField<String>('default_price');

  /// Unix seconds.
  final created = CvField<int>('created');

  /// Unix seconds.
  final updated = CvField<int>('updated');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  @override
  List<CvField<Object?>> get fields => [
    id,
    name,
    description,
    taxCode,
    active,
    defaultPrice,
    created,
    updated,
    livemode,
    ...metadataMixinFields,
  ];
}

/// https://stripe.com/docs/api/products/create
class StripeApiProductListOptions extends CvModelBase {
  /// limit (optional)
  /// A limit on the number of objects to be returned. Limit can range between
  /// 1 and 100, and the default is 10.
  final limit = CvField<int>('limit');

  /// starting_after (optional)
  /// A cursor for use in pagination. starting_after is an object ID that
  /// defines your place in the list. For instance, if you make a list request
  /// and receive 100 objects, ending with obj_foo, your subsequent call can
  /// include starting_after=obj_foo in order to fetch the next page of the list.
  final startingAfter = CvField<String>('starting_after');

  /// Active ones only (true) or archived ones only (false), all when null.
  final active = CvField<bool>('active');

  @override
  List<CvField<Object?>> get fields => [limit, startingAfter, active];
}

class StripeApiProductList extends CvModelBase {
  final hasMore = CvField<bool>('has_more');
  final data = CvModelListField<StripeApiProduct>('data');
  @override
  List<CvField<Object?>> get fields => [data, hasMore];
}
