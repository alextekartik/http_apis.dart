import 'package:cv/cv.dart';

import 'line_item.dart';
import 'list_options.dart';
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

/// `automatic_tax` of a Checkout Session: the tax computed by Stripe Tax
/// from the customer's address (Stripe Tax set up in the dashboard).
class StripeApiCheckoutAutomaticTax extends CvModelBase {
  /// true to compute the tax.
  final enabled = CvField<bool>('enabled');

  @override
  CvFields get fields => [enabled];
}

/// `tax_id_collection` of a Checkout Session: a business customer may give
/// its tax id (an EU VAT number).
class StripeApiCheckoutTaxIdCollection extends CvModelBase {
  /// true to offer it.
  final enabled = CvField<bool>('enabled');

  @override
  CvFields get fields => [enabled];
}

/// `customer_update` of a Checkout Session for an existing customer: what
/// Checkout saves on it, `auto` (needed by the automatic tax and the tax id
/// collection) or `never`.
class StripeApiCheckoutCustomerUpdate extends CvModelBase {
  /// The address given.
  final address = CvField<String>('address');

  /// The name given (the business name with a tax id).
  final name = CvField<String>('name');

  @override
  CvFields get fields => [address, name];
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

  /// The tax computed by Stripe Tax.
  final automaticTax = CvModelField<StripeApiCheckoutAutomaticTax>(
    'automatic_tax',
  );

  /// `auto` (only when needed, by the tax for instance) or `required`.
  final billingAddressCollection = CvField<String>(
    'billing_address_collection',
  );

  /// What Checkout saves on the existing [customer].
  final customerUpdate = CvModelField<StripeApiCheckoutCustomerUpdate>(
    'customer_update',
  );

  /// The tax id of a business customer.
  final taxIdCollection = CvModelField<StripeApiCheckoutTaxIdCollection>(
    'tax_id_collection',
  );

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
    automaticTax,
    billingAddressCollection,
    customerUpdate,
    taxIdCollection,
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

  /// Cents, after discounts and taxes.
  final amountTotal = CvField<int>('amount_total');

  /// Cents, before discounts and taxes.
  final amountSubtotal = CvField<int>('amount_subtotal');

  /// `eur`...
  final currency = CvField<String>('currency');

  /// Unix seconds.
  final created = CvField<int>('created');

  /// The email given to create the session.
  final customerEmail = CvField<String>('customer_email');

  /// Who paid (email, name, phone), once complete.
  final customerDetails = CvModelField<StripeApiCheckoutCustomerDetails>(
    'customer_details',
  );

  /// The payment intent id of a `payment` session.
  final paymentIntent = CvField<String>('payment_intent');

  /// The Payment Link that opened the session (`plink_...`), if any.
  final paymentLink = CvField<String>('payment_link');

  /// The line items, when expanded (`expand: ['data.line_items']` in a list,
  /// `line_items` for one session).
  final lineItems = CvModelField<StripeApiLineItemList>('line_items');

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
    amountTotal,
    amountSubtotal,
    currency,
    created,
    customerEmail,
    customerDetails,
    paymentIntent,
    paymentLink,
    lineItems,
    ...metadataMixinFields,
  ];
}

/// `status` of a completed Checkout Session.
const stripeCheckoutSessionStatusComplete = 'complete';

/// `status` of an expired Checkout Session.
const stripeCheckoutSessionStatusExpired = 'expired';

/// `status` of an open Checkout Session.
const stripeCheckoutSessionStatusOpen = 'open';

/// `payment_status` of a paid Checkout Session.
const stripeCheckoutSessionPaymentStatusPaid = 'paid';

/// `customer_details` of a Checkout Session.
class StripeApiCheckoutCustomerDetails extends CvModelBase {
  /// The email.
  final email = CvField<String>('email');

  /// The name.
  final name = CvField<String>('name');

  /// The phone, when collected.
  final phone = CvField<String>('phone');

  @override
  CvFields get fields => [email, name, phone];
}

/// A page of Checkout Sessions.
class StripeApiCheckoutSessionList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The sessions, newest first.
  final data = CvModelListField<StripeApiCheckoutSession>('data');

  @override
  CvFields get fields => [data, hasMore];
}

/// https://docs.stripe.com/api/checkout/sessions/list
class StripeApiCheckoutSessionListOptions extends CvModelBase
    with StripeApiListOptionsMixin {
  /// The sessions of a Payment Link (`plink_...`).
  final paymentLink = CvField<String>('payment_link');

  /// The sessions of a payment intent.
  final paymentIntent = CvField<String>('payment_intent');

  /// The sessions of a customer.
  final customer = CvField<String>('customer');

  /// [stripeCheckoutSessionStatusComplete]...
  final status = CvField<String>('status');

  @override
  CvFields get fields => [
    paymentLink,
    paymentIntent,
    customer,
    status,
    ...listOptionsMixinFields,
  ];

  /// The query parameters.
  Map<String, Object> toQueryParameters() => {
    ...listQueryParameters(),
    'payment_link': ?paymentLink.v,
    'payment_intent': ?paymentIntent.v,
    'customer': ?customer.v,
    'status': ?status.v,
  };
}
