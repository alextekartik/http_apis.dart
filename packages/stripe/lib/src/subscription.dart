import 'package:cv/cv.dart';

import 'stripe_models.dart';

/// Subscription statuses.
const stripeSubscriptionStatusActive = 'active';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusTrialing = 'trialing';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusPastDue = 'past_due';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusCanceled = 'canceled';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusUnpaid = 'unpaid';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusIncomplete = 'incomplete';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusIncompleteExpired = 'incomplete_expired';

/// See [stripeSubscriptionStatusActive].
const stripeSubscriptionStatusPaused = 'paused';

/// A subscription (the `customer.subscription.*` object too).
///
/// Its period end is on its items since the API version 2025-03-31 and on the
/// subscription before: [currentPeriodEndSeconds] reads either.
class StripeApiSubscription extends CvModelBase with StripeApiMetadataMixin {
  /// `sub_...`.
  final id = CvField<String>('id');

  /// The customer id.
  final customer = CvField<String>('customer');

  /// See [stripeSubscriptionStatusActive].
  final status = CvField<String>('status');

  /// Ends at the end of the period.
  final cancelAtPeriodEnd = CvField<bool>('cancel_at_period_end');

  /// Ends then (unix seconds).
  final cancelAt = CvField<int>('cancel_at');

  /// Ended then (unix seconds).
  final endedAt = CvField<int>('ended_at');

  /// The period end before the API version 2025-03-31 (unix seconds).
  final currentPeriodEnd = CvField<int>('current_period_end');

  /// The items (`data`: price, current_period_end...), as Stripe sends them.
  final items = CvField<Model>('items');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  /// The first item.
  Map<String, Object?>? get _firstItem {
    var data = items.v?['data'];
    if (data is List && data.isNotEmpty && data.first is Map) {
      return (data.first as Map).cast<String, Object?>();
    }
    return null;
  }

  Map<String, Object?>? get _price {
    var price = _firstItem?['price'];
    return price is Map ? price.cast<String, Object?>() : null;
  }

  /// The end of the current period (unix seconds).
  int? get currentPeriodEndSeconds =>
      currentPeriodEnd.v ??
      (_firstItem?['current_period_end'] as num?)?.toInt();

  /// The price id of the first item.
  String? get priceId => _price?['id'] as String?;

  /// The lookup key of the price of the first item.
  String? get priceLookupKey => _price?['lookup_key'] as String?;

  /// The currency of the price of the first item.
  String? get priceCurrency => _price?['currency'] as String?;

  /// The interval (`month`, `year`) of the price of the first item.
  String? get priceInterval {
    var recurring = _price?['recurring'];
    return recurring is Map ? recurring['interval'] as String? : null;
  }

  @override
  CvFields get fields => [
    id,
    customer,
    status,
    cancelAtPeriodEnd,
    cancelAt,
    endedAt,
    currentPeriodEnd,
    items,
    livemode,
    ...metadataMixinFields,
  ];
}

/// https://docs.stripe.com/api/subscriptions/update
class StripeApiSubscriptionUpdate extends CvModelBase
    with StripeApiMetadataMixin {
  /// Ends at the end of the period (true), or goes on (false).
  final cancelAtPeriodEnd = CvField<bool>('cancel_at_period_end');

  @override
  CvFields get fields => [cancelAtPeriodEnd, ...metadataMixinFields];
}
