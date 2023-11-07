class StripeApiPriceOptions {
  final String productId;
  final double amount;
  final String currency;
  final StringApiPriceRecurring? recurring;

  StripeApiPriceOptions(
      {required this.amount,
      required this.currency,
      required this.productId,
      this.recurring});
}

/// Optional recurring.
/// 'month', 3 means every 3 months.
class StringApiPriceRecurring {
  final String interval;
  final int intervalCount;

  StringApiPriceRecurring(
      {required this.interval, required this.intervalCount});
}
