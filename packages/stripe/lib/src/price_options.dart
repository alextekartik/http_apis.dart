import 'api_options.dart';

class StripeApiPriceOptions {
  final String productId;
  final double amount;
  final String currency;
  final StringApiPriceRecurring? recurring;
  final StripeApiMetadata? metadata;

  /// A brief description of the price, hidden from customers.
  final String? nickname;

  StripeApiPriceOptions(
      {required this.amount,
      required this.currency,
      required this.productId,
      this.nickname,
      this.recurring,
      this.metadata});
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
class StringApiPriceRecurring {
  final String interval;
  final int intervalCount;

  StringApiPriceRecurring(
      {required this.interval, required this.intervalCount});
}
