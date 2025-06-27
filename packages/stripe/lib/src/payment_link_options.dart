import 'package:cv/cv.dart';

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

  List<CvField<Object?>> get createUpdateMixinFields => [
    lineItems,
    metadata,
    subscriptionData,
    active,
  ];
}

/// https://stripe.com/docs/api/payment_links/payment_links/create
class StripeApiPaymentLinkUpdate extends CvModelBase
    with StripeApiPaymentLinkCreateUpdateMixin {
  @override
  List<CvField<Object?>> get fields => [...createUpdateMixinFields];
}
