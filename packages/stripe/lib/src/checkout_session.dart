import 'package:cv/cv.dart';

import 'stripe_models.dart';

/// A Checkout Session for a subscription.
const stripeCheckoutModeSubscription = 'subscription';

/// A Checkout Session for a one time payment.
const stripeCheckoutModePayment = 'payment';

/// A line item of a Checkout Session: a price and its quantity.
class StripeApiCheckoutLineItem extends CvModelBase {
  /// The price id.
  final priceId = CvField<String>('price');

  /// The quantity, 1 usually.
  final quantity = CvField<int>('quantity');

  @override
  CvFields get fields => [priceId, quantity];
}

/// `subscription_data` of a Checkout Session: what the subscription made
/// gets (its metadata).
class StripeApiCheckoutSubscriptionData extends CvModelBase
    with StripeApiMetadataMixin {
  /// The description of the subscription.
  final description = CvField<String>('description');

  @override
  CvFields get fields => [description, ...metadataMixinFields];
}

/// `consent_collection` of a Checkout Session.
class StripeApiCheckoutConsentCollection extends CvModelBase {
  /// `required` to have the terms of service accepted (the terms url set in
  /// the Stripe dashboard).
  final termsOfService = CvField<String>('terms_of_service');

  @override
  CvFields get fields => [termsOfService];
}

/// https://docs.stripe.com/api/checkout/sessions/create
class StripeApiCheckoutSessionCreate extends CvModelBase
    with StripeApiMetadataMixin {
  /// [stripeCheckoutModeSubscription] or [stripeCheckoutModePayment].
  final mode = CvField<String>('mode');

  /// Where Stripe goes once paid (`{CHECKOUT_SESSION_ID}` replaced).
  final successUrl = CvField<String>('success_url');

  /// Where Stripe goes when the customer gives up.
  final cancelUrl = CvField<String>('cancel_url');

  /// Your own id of the customer (a user id), in the completed session.
  final clientReferenceId = CvField<String>('client_reference_id');

  /// An existing customer id.
  final customer = CvField<String>('customer');

  /// The email of a new customer.
  final customerEmail = CvField<String>('customer_email');

  /// `auto`, `fr`, `en`...
  final locale = CvField<String>('locale');

  /// The prices.
  final lineItems = CvModelListField<StripeApiCheckoutLineItem>('line_items');

  /// What the subscription gets.
  final subscriptionData = CvModelField<StripeApiCheckoutSubscriptionData>(
    'subscription_data',
  );

  /// The consents to collect.
  final consentCollection = CvModelField<StripeApiCheckoutConsentCollection>(
    'consent_collection',
  );

  /// Promotion codes allowed.
  final allowPromotionCodes = CvField<bool>('allow_promotion_codes');

  @override
  CvFields get fields => [
    mode,
    successUrl,
    cancelUrl,
    clientReferenceId,
    customer,
    customerEmail,
    locale,
    lineItems,
    subscriptionData,
    consentCollection,
    allowPromotionCodes,
    ...metadataMixinFields,
  ];
}

/// A Checkout Session (the `checkout.session.completed` object too).
class StripeApiCheckoutSession extends CvModelBase with StripeApiMetadataMixin {
  /// `cs_...`.
  final id = CvField<String>('id');

  /// The page to open.
  final url = CvField<String>('url');

  /// See [StripeApiCheckoutSessionCreate.mode].
  final mode = CvField<String>('mode');

  /// `open`, `complete`, `expired`.
  final status = CvField<String>('status');

  /// `paid`, `unpaid`, `no_payment_required`.
  final paymentStatus = CvField<String>('payment_status');

  /// See [StripeApiCheckoutSessionCreate.clientReferenceId].
  final clientReferenceId = CvField<String>('client_reference_id');

  /// The customer id, once known.
  final customer = CvField<String>('customer');

  /// The subscription id, once made.
  final subscription = CvField<String>('subscription');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  @override
  CvFields get fields => [
    id,
    url,
    mode,
    status,
    paymentStatus,
    clientReferenceId,
    customer,
    subscription,
    livemode,
    ...metadataMixinFields,
  ];
}
