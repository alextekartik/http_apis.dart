import 'package:cv/cv.dart';

import 'list_options.dart';

class StripeApiPaymentLinkSubscriptionData extends CvModelBase {
  final description = CvField<String>('description');

  @override
  List<CvField<Object?>> get fields => [description];
}

class StripeApiPaymentLinkLineItem extends CvModelBase {
  /// Required
  /// The ID of the Price or Plan object.
  final priceId = CvField<String>('price');

  /// Required
  /// The quantity of the line item being purchased.
  /// Default to 1
  final quantity = CvField<int>('quantity');

  @override
  List<CvField<Object?>> get fields => [priceId, quantity];
}

/// `restrictions.completed_sessions` of a Payment Link.
class StripeApiPaymentLinkCompletedSessions extends CvModelBase {
  /// The link deactivates itself after this many completed payments (1 for
  /// a link made for one order).
  final limit = CvField<int>('limit');

  @override
  List<CvField<Object?>> get fields => [limit];
}

/// `restrictions` of a Payment Link.
class StripeApiPaymentLinkRestrictions extends CvModelBase {
  /// See [StripeApiPaymentLinkCompletedSessions].
  final completedSessions = CvModelField<StripeApiPaymentLinkCompletedSessions>(
    'completed_sessions',
  );

  @override
  List<CvField<Object?>> get fields => [completedSessions];
}

/// https://stripe.com/docs/api/payment_links/payment_links/create
class StripeApiPaymentLinkCreate extends CvModelBase
    with StripeApiPaymentLinkCreateUpdateMixin {
  @override
  List<CvField<Object?>> get fields => [...createUpdateMixinFields];
}

mixin StripeApiPaymentLinkCreateUpdateMixin on CvModelBase {
  final lineItems = CvModelListField<StripeApiPaymentLinkLineItem>(
    'line_items',
  );
  final metadata = CvField<Model>('metadata');

  /// Optional only valid if one line item is a recurring subscription.
  final subscriptionData = CvModelField<StripeApiPaymentLinkSubscriptionData>(
    'subscription_data',
  );
  final active = CvField<bool>('active');

  /// Optional, a limit of completed payments
  /// ([StripeApiPaymentLinkRestrictions]).
  final restrictions = CvModelField<StripeApiPaymentLinkRestrictions>(
    'restrictions',
  );

  List<CvField<Object?>> get createUpdateMixinFields => [
    lineItems,
    metadata,
    subscriptionData,
    active,
    restrictions,
  ];
}

/// https://stripe.com/docs/api/payment_links/payment_links/create
class StripeApiPaymentLinkUpdate extends CvModelBase
    with StripeApiPaymentLinkCreateUpdateMixin {
  @override
  List<CvField<Object?>> get fields => [...createUpdateMixinFields];
}

/// https://docs.stripe.com/api/payment_links/payment_links/list
class StripeApiPaymentLinkListOptions extends CvModelBase
    with StripeApiListOptionsMixin {
  /// Active ones only (true) or inactive ones only (false).
  final active = CvField<bool>('active');

  @override
  List<CvField<Object?>> get fields => [active, ...listOptionsMixinFields];

  /// The query parameters.
  Map<String, Object> toQueryParameters() => {
    ...listQueryParameters(),
    if (active.v case var active?) 'active': '$active',
  };
}
