import 'package:cv/cv.dart';
import 'package:tekartik_stripe_api/src/price_options.dart';

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
class StripeApiPrice extends CvModelBase
    with StripeApiPriceMixin, StripeApiMetadataMixin {
  final id = CvField<String>('id');

  @override
  List<CvField<Object?>> get fields =>
      [id, ...priceMixinFields, ...metadataMixinFields];
}
