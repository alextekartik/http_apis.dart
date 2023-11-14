import 'package:cv/cv.dart';

import 'api_options.dart';

class StripeApiPaymentLinkSubscriptionDataOld {
  final String? description;

  StripeApiPaymentLinkSubscriptionDataOld({required this.description});
}

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

class StripeApiPaymentLinkPriceOptionsOld {
  final String priceId;

  /// Default to 1
  final int? quantity;

  StripeApiPaymentLinkPriceOptionsOld({
    required this.priceId,
    this.quantity,
  });
}

class StripeApiPaymentLinkOptionsOld {
  final List<StripeApiPaymentLinkPriceOptionsOld> prices;
  final StripeApiMetadata? metadata;
  final StripeApiPaymentLinkSubscriptionDataOld? subscriptionData;
  StripeApiPaymentLinkOptionsOld({
    required this.prices,
    this.metadata,
    this.subscriptionData,
  });
}

class StripeApiPaymentLinkCreate extends CvModelBase {
  final lineItems =
      CvModelListField<StripeApiPaymentLinkLineItem>('line_items');
  final metadata = CvField<Model>('metadata');

  /// Optional only valid if one line item is a recurring subscription.
  final subscriptionData =
      CvModelField<StripeApiPaymentLinkSubscriptionData>('subscription_data');

  @override
  List<CvField<Object?>> get fields => [lineItems, metadata, subscriptionData];
}
