import 'package:cv/cv.dart';

import 'api_options.dart';
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
  /*
  final double amount;
  final String currency;
  final StringApiPriceRecurringOld? recurring;
  final StripeApiMetadata? metadata;

  /// A brief description of the price, hidden from customers.
  final String? nickname;

  StripeApiPriceOptionsOld(
      {required this.amount,
        required this.currency,
        required this.productId,
        this.nickname,
        this.recurring,
        this.metadata});

   */
}

@Deprecated('old')
class StripeApiPriceOptionsOld {
  final String productId;
  final double amount;
  final String currency;
  final StringApiPriceRecurringOld? recurring;
  final StripeApiMetadata? metadata;

  /// A brief description of the price, hidden from customers.
  final String? nickname;

  StripeApiPriceOptionsOld(
      {required this.amount,
      required this.currency,
      required this.productId,
      this.nickname,
      this.recurring,
      this.metadata});
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
@Deprecated('old')
class StringApiPriceRecurringOld {
  final String interval;
  final int intervalCount;

  StringApiPriceRecurringOld(
      {required this.interval, required this.intervalCount});
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
class StringApiPriceRecurring extends CvModelBase {
  final interval = CvField<String>('interval');
  final intervalCount = CvField<int>('interval_count');

  @override
  List<CvField<Object?>> get fields => [interval, intervalCount];
}
